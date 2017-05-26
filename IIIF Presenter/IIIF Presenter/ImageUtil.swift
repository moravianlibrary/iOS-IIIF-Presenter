//
//  File.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 28/04/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ImageUtil {
    
    fileprivate let TAG = "ImageUtil: "
    fileprivate var request: URLSessionDataTask?
    
    fileprivate var visited = Set<String>()
    fileprivate var cacheKey = "default"
    
    func getFirstImage(_ resource: Any?, completion: @escaping ((UIImage?) -> Swift.Void)) {
        stopLoading()
        if let m = resource as? IIIFManifest {
            getFirstImage(manifest: m, completion: completion)
        } else if let c = resource as? IIIFCollection {
            getFirstImage(collection: c, completion: completion)
        } else {
            assertionFailure(TAG + "Unsupported resource type: \(resource ?? "nil"))")
        }
    }
    
    func stopLoading() {
        cacheKey = "default"
        request?.cancel()
        request = nil
        visited.removeAll()
    }
    
    fileprivate func getFirstImage(manifest: IIIFManifest, completion: @escaping ((UIImage?) -> Swift.Void)) {
        if let img = getCachedImage(manifest.id.absoluteString) {
            completion(img)
        } else {
            cacheKey = manifest.id.absoluteString
            let thumbnails = getManifestThumbnails(manifest)
            downloadThumbnail(thumbnails, key: cacheKey, completion: completion)
        }
    }
    
    fileprivate func getFirstImage(collection: IIIFCollection, completion: @escaping ((UIImage?) -> Swift.Void)) {
        if let img = getCachedImage(collection.id.absoluteString) {
            completion(img)
        } else {
            cacheKey = collection.id.absoluteString
            let thumbnails = getCollectionThumbnails(collection)
            downloadThumbnail(thumbnails, key: cacheKey, completion: completion)
        }
    }
    
    // Try to download thumbnail from first url in list. If it fails, keep continue until the list is empty. Return first result with success or nil in completion block.
    fileprivate func downloadThumbnail(_ list: [String], key: String, completion: @escaping ((UIImage?) -> Swift.Void)) {
        guard !list.isEmpty, cacheKey == key else {
            completion(nil)
            return
        }
        
        var array = list
        let urlString = IIIFImageApi.cropImageUrl(urlString: array.remove(at: 0))
        
        guard !visited.contains(urlString) else {
            downloadThumbnail(array, key: key, completion: completion)
            return
        }
        
        visited.insert(urlString)
        log("Try thumbnail at \(urlString).")
        if let url = URL(string: urlString) {
            request = SessionPool.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                if (error as NSError?)?.code == NSURLErrorCancelled {
                    completion(nil)
                    return
                } else if data != nil {
                    if let img = UIImage(data: data!) {
                        SDImageCache.shared().store(img, forKey: self.cacheKey)
                        completion(img)
                        return
                    } else {
                        if data!.count > 1000000 {
                            // don't you dare to parse files over 1MB
                            log("Size of data exceeded (\(data!.count)).", level: .Verbose)
                            self.downloadThumbnail(array, key: key, completion: completion)
                            return
                        }
                        
                        let serialized = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        if let json = serialized as? [String:Any] {
                            if let img = IIIFImageApi(json) {
                                let sUrl = img.getThumbnailUrl()
                                if !self.visited.contains(sUrl) && !array.contains(sUrl) {
                                    array.insert(sUrl, at: 0)
                                }
                            } else if let m = IIIFManifest(json) {
                                for sUrl in self.getManifestThumbnails(m).reversed()
                                    where !array.contains(sUrl) && !self.visited.contains(sUrl) {
                                        array.insert(sUrl, at: 0)
                                }
                            } else if let c = IIIFCollection(json) {
                                for sUrl in self.getCollectionThumbnails(c).reversed()
                                    where !array.contains(sUrl) && !self.visited.contains(sUrl) {
                                        array.insert(sUrl, at: 0)
                                }
                            }
                        }
                    }
                }
                
                self.downloadThumbnail(array, key: key, completion: completion)
            })
            request?.resume()
        } else {
            downloadThumbnail(array, key: key, completion: completion)
        }
    }
    
    // Gather all possible thumbnail url (thumbnail or manifest) for collection
    fileprivate func getCollectionThumbnails(_ collection: IIIFCollection) -> [String] {
        var listOfThumbnailUrls = [String]()
        
        if let thumbnail = collection.thumbnail {
            listOfThumbnailUrls.append(thumbnail.id)
        }
        
        if let items = collection.members {
            // try manifests first as it may laed to faster image result 
            for case let item as IIIFManifest in items {
                listOfThumbnailUrls.append(contentsOf: getManifestThumbnails(item))
            }
            for case let item as IIIFCollection in items {
                listOfThumbnailUrls.append(contentsOf: getCollectionThumbnails(item))
            }
        } else {
            // collection needs to be loaded first
            listOfThumbnailUrls.append(collection.id.absoluteString)
        }
        
        return listOfThumbnailUrls
    }
    
    // Gather all possible thumbnail url (thumbnail or canvas) for manifest
    fileprivate func getManifestThumbnails(_ manifest: IIIFManifest) -> [String] {
        var listOfThumbnailUrls = [String]()
        
        if let thumbnail = manifest.thumbnail {
            listOfThumbnailUrls.append(thumbnail.id)
        }
        
        if let sequences = manifest.sequences {
            for sequence in sequences {
                if let thumbnails = sequence.thumbnail?.getValueList() {
                    listOfThumbnailUrls.append(contentsOf: thumbnails)
                }
                
                for canvas in sequence.canvases {
                    if let thumbnails = canvas.thumbnail?.getValueList() {
                        listOfThumbnailUrls.append(contentsOf: thumbnails)
                    }
                    
                    if let images = canvas.images {
                        for image in images {
                            if let value = image.resource.service?.id {
                                listOfThumbnailUrls.append(value)
                            }
                            
                            listOfThumbnailUrls.append(image.resource.id)
                        }
                    }
                }
            }
        } else {
            // manifest needs to be loaded first
            listOfThumbnailUrls.append(manifest.id.absoluteString)
        }
        
        return listOfThumbnailUrls
    }
    
    fileprivate func getCachedImage(_ imgKey: String) -> UIImage? {
        return SDImageCache.shared().imageFromMemoryCache(forKey: imgKey) ?? SDImageCache.shared().imageFromDiskCache(forKey: imgKey) ?? nil
    }
}

//class ImageUtil {
//
//    fileprivate var request: URLSessionDataTask?
//    fileprivate var session: URLSession!
//    fileprivate var sessionTasks = 0
//    
//    init() {
//        createSession()
//    }
//    
//    func createSession() {
//        let config = URLSessionConfiguration.default
//        config.urlCache = nil
//        config.urlCredentialStorage = nil
//        config.httpCookieStorage = nil
//        session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
//    }
//    
//    func getFirstImage(_ resource: Any?, completion: @escaping ((UIImage?) -> Swift.Void)) {
//        stopLoading()
//        createSession()
//        if let m = resource as? IIIFManifest {
//            getFirstImage(manifest: m, completion: completion)
//        } else if let c = resource as? IIIFCollection {
//            getFirstImage(collection: c, completion: completion)
//        } else {
//            assertionFailure(TAG + "Unsupported resource type: \(resource ?? "nil"))")
//        }
//    }
//    
//    func stopLoading() {
//        cacheKey = "default"
//        request?.cancel()
//        request = nil
//        session.invalidateAndCancel()
//        visited.removeAll()
//    }
//    
//    // Try to download thumbnail from first url in list. If it fails, keep continue until the list is empty. Return first result with success or nil in completion block.
//    fileprivate func downloadThumbnail(_ list: [String], key: String, completion: @escaping ((UIImage?) -> Swift.Void)) {
//        guard !list.isEmpty, cacheKey == key else {
//            completion(nil)
//            return
//        }
//        
//        var array = list
//        let urlString = IIIFImageApi.cropImageUrl(urlString: array.remove(at: 0))
//        
//        guard !visited.contains(urlString) else {
//            downloadThumbnail(array, key: key, completion: completion)
//            return
//        }
//        
//        if sessionTasks < 20 {
//            session.flush {}
//            session.reset {}
//            sessionTasks = 0
//        }
//        
//        visited.insert(urlString)
//        log("Try thumbnail at \(urlString).")
//        if let url = URL(string: urlString) {
//            sessionTasks += 1
//            request = SessionPool.shared.dataTask(with: url, completionHandler: { (data, response, error) in
//                //            request = session.dataTask(with: url, completionHandler: { (data, response, error) in
//                
//                if (error as NSError?)?.code == NSURLErrorCancelled {
//                    completion(nil)
//                    return
//                } else if data != nil {
//                    if let img = UIImage(data: data!) {
//                        SDImageCache.shared().store(img, forKey: self.cacheKey)
//                        completion(img)
//                        return
//                    } else {
//                        if data!.count > 1000000 {
//                            // don't you dare to parse files over 1MB
//                            log("Size of data exceeded (\(data!.count)).", level: .Verbose)
//                            self.downloadThumbnail(array, key: key, completion: completion)
//                            return
//                        }
//                        
//                        let serialized = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
//                        if let json = serialized as? [String:Any] {
//                            if let img = IIIFImageApi(json) {
//                                let sUrl = img.getThumbnailUrl()
//                                if !self.visited.contains(sUrl) && !array.contains(sUrl) {
//                                    array.insert(sUrl, at: 0)
//                                }
//                            } else if let m = IIIFManifest(json) {
//                                for sUrl in self.getManifestThumbnails(m).reversed()
//                                    where !array.contains(sUrl) && !self.visited.contains(sUrl) {
//                                        array.insert(sUrl, at: 0)
//                                }
//                            } else if let c = IIIFCollection(json) {
//                                for sUrl in self.getCollectionThumbnails(c).reversed()
//                                    where !array.contains(sUrl) && !self.visited.contains(sUrl) {
//                                        array.insert(sUrl, at: 0)
//                                }
//                            }
//                        }
//                    }
//                }
//                
//                self.downloadThumbnail(array, key: key, completion: completion)
//            })
//            request?.resume()
//        } else {
//            downloadThumbnail(array, key: key, completion: completion)
//        }
//    }
//}


fileprivate class SessionPool {
    
    private static let instance = SessionPool()
    static var shared: SessionPool {
        return instance
    }
    
    private final let capacity = 2
    private var pool: [(session: URLSession, taskCount: Int)]
    
    private var leastUsedSession: URLSession {
        return pool.sorted(by: { $0.0.taskCount < $0.1.taskCount }).first!.session
    }
    
    private init() {
        var pool_ = [(URLSession, Int)]()
        for _ in 1...capacity {
            let config = URLSessionConfiguration.default
            config.urlCache = nil
            config.httpCookieStorage = nil
            config.urlCredentialStorage = nil
            pool_.append((URLSession(configuration: config),0))
        }
        pool = pool_
    }
    
    private func changeTaskCount(_ session: URLSession, _ value: Int) {
        for (index, tuple) in pool.enumerated() where tuple.session === session {
            pool[index].taskCount += value
        }
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
        let session = leastUsedSession
        changeTaskCount(session, 1)
        return session.dataTask(with: url) {(data, response, error) in
            self.changeTaskCount(session, -1)
            completionHandler(data, response, error)
        }
    }
}
