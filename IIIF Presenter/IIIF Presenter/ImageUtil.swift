//
//  File.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 28/04/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation
import UIKit

class ImageUtil {
    
    fileprivate let TAG = "ImageUtil: "
    fileprivate var request: URLSessionDataTask?
    fileprivate var visited = Set<String>()
    fileprivate var stop = false
    
    func getFirstImage(_ resource: Any?, completion: @escaping ((Data?) -> Swift.Void)) {
        request?.cancel()
        stop = false
        if let m = resource as? IIIFManifest {
            getFirstImage(manifest: m, completion: completion)
        } else if let c = resource as? IIIFCollection {
            getFirstImage(collection: c, completion: completion)
        } else {
            assertionFailure(TAG + "Unsupported resource type: \(resource ?? "nil"))")
        }
    }
    
    func stopLoading() {
        stop = true
        request?.cancel()
        visited.removeAll()
    }
    
    fileprivate func getFirstImage(manifest: IIIFManifest, completion: @escaping ((Data?) -> Swift.Void)) {
        let thumbnails = getManifestThumbnails(manifest)
        downloadThumbnail(thumbnails, completion: completion)
    }
    
    fileprivate func getFirstImage(collection: IIIFCollection, completion: @escaping ((Data?) -> Swift.Void)) {
        let thumbnails = getCollectionThumbnails(collection)
        downloadThumbnail(thumbnails, completion: completion)
    }
    
    // Try to download thumbnail from first url in list. If it fails, keep continue until the list is empty. Return first result with success or nil in completion block.
    fileprivate func downloadThumbnail(_ list: [String], completion: @escaping ((Data?) -> Swift.Void)) {
        guard !list.isEmpty, !stop else {
            completion(nil)
            return
        }
        
        var array = list
        let urlString = array.remove(at: 0)
        
        guard !visited.contains(urlString) else {
            downloadThumbnail(array, completion: completion)
            return
        }
        
        visited.insert(urlString)
        print("Try thumbnail at \(urlString).")
        if let url = URL(string: urlString) {
            request = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                if (error as NSError?)?.code == NSURLErrorCancelled {
                    completion(nil)
                    return
                } else if data != nil {
                    if let _ = UIImage(data: data!) {
                        completion(data)
                        return
                    } else if let serialized = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                        
                        let json = serialized as! [String:Any]
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
                
                self.downloadThumbnail(array, completion: completion)
            })
            request?.resume()
        } else {
            downloadThumbnail(array, completion: completion)
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
}
