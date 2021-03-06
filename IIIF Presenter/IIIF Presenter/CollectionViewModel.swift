//
//  CollectionViewModel.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation
import Bond

class CollectionViewModel {

    // observable data from collection
    var data = MutableObservableArray<Any>([])

    var collection: IIIFCollection
    var delegate: CardListDelegate?
    var loadingError: NSError?
    
    var itemsCount: Int {
        return collection.members?.count ?? 0
    }
    var isLoading: Bool {
        return request != nil || (toDownload != nil && !toDownload!.isEmpty)
    }
    
    fileprivate var cachedResponses = [(index: Int, item: Any)]()
    fileprivate var brokenResponses = [Int]()
    fileprivate var collectionCountOffset = 0
    public fileprivate(set) var collectionTotalCount = -1
    
    fileprivate var request: URLSessionDataTask?
    fileprivate var toDownload: [Any]?
    fileprivate let session: URLSession = URLSession.shared
    
    static func createWithUrl(_ url: String, delegate: CardListDelegate?, items: [Any]?=nil) -> CollectionViewModel {
        return CollectionViewModel(url, delegate, items)
    }
    
    init(_ collection: IIIFCollection) {
        self.collection = collection
        if collection.members == nil {
            downloadData(collection.id)
        } else if !collection.members!.isEmpty {
            toDownload = self.collection.members
            self.collection.members = nil
        }
    }
    
    fileprivate init(_ urlString: String, _ delegate: CardListDelegate?, _ items: [Any]?) {
        let url = URL(string: urlString)!
        collection = IIIFCollection.createCollectionWith(url, members: items)
        self.delegate = delegate
    }
    
    
    fileprivate func downloadData(_ url: URL) {
        delegate?.didStartLoadingData()
        request = session.dataTask(with: url, completionHandler: { (data, response, error) in
            var err: NSError? = nil
            if (error as NSError?)?.code == NSURLErrorCancelled {
                return
            } else if data != nil,
                let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                let json = serialization as! [String:Any]
                if let c = IIIFCollection(json) {
                    self.collection = c
                    self.toDownload = self.collection.members
                    self.collection.members = nil
                } else if let m = IIIFManifest(json) {
                    self.collection.members!.insert(m, at: 0)
                } else {
                    err = NSError(domain: "cz.mzk", code: 102, userInfo: [NSLocalizedDescriptionKey: ["en":"Parsing error", "cz":"Chyba parsovani"]])
                    log("Unknown IIIF structure at \(url.absoluteString).", level: .Error)
                }
            } else if error != nil {
                err = error as NSError?
                log("Request error from \(url.absoluteString).", level: .Error)
            } else {
                err = NSError(domain: "cz.mzk", code: 101, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("intern_error", comment: "")])
                log("Parsing error from \(url.absoluteString).", level: .Error)
            }
            
            self.loadingError = err
            self.loadAllMembers()
        })
        request?.resume()
    }
    
    fileprivate var _session: URLSession?
    fileprivate var allSession: URLSession {
        if _session == nil {
            let config = URLSessionConfiguration.default
            config.urlCache = URLCache.shared
            config.httpCookieStorage = nil
            config.urlCredentialStorage = nil
            _session = URLSession(configuration: config)
        }
        return _session!
    }
    
    fileprivate func loadAllMembers() {
        request = nil
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.loadAllMembers()
            }
            return
        }
        
        guard toDownload != nil, !toDownload!.isEmpty else {
            delegate?.didFinishLoadingData(error: loadingError)
            return
        }
        
        collectionTotalCount = toDownload!.count
        collectionCountOffset = 0
        let session = allSession
        var url: URL?
        for (index,item) in toDownload!.enumerated() {
            if let m = item as? IIIFManifest {
                url = m.id
            } else if let c = item as? IIIFCollection {
                url = c.id
            } else if let s = item as? String, let u = URL(string: s) {
                url = u
            } else {
                toDownload!.remove(at: index)
                url = nil
            }
            
            if let _url = url {
                session.dataTask(with: _url, completionHandler: { (data, _, error) in
                    if (error as NSError?)?.code == NSURLErrorCancelled {
                        return
                    }
                    
                    self.deleteItem(_url.absoluteString)
                    if data != nil, let serialized = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                        
                        let json = serialized as! [String:Any]
                        DispatchQueue.main.async {
                            if let c = IIIFCollection(json) {
                                self.addItem(item: c, atIndex: index)
                            } else if let m = IIIFManifest(json) {
                                self.addItem(item: m, atIndex: index)
                            } else {
                                self.brokenResponses.append(index)
                            
                                if index == self.itemsCount {
                                    self.collectionCountOffset += 1
                                    self.checkCacheAfter(index)
                                }
                                
                                if self.toDownload!.isEmpty {
                                    self.delegate?.didFinishLoadingData(error: self.loadingError)
                                }
                            }
                        }
                    } else {
                        self.brokenResponses.append(index)
                        DispatchQueue.main.async {
                            if index == self.itemsCount {
                                self.collectionCountOffset += 1
                                self.checkCacheAfter(index)
                            }
                            
                            if self.toDownload!.isEmpty {
                                self.delegate?.didFinishLoadingData(error: self.loadingError)
                            }
                        }
                    }
                }).resume()
            }
        }
    }
    
    fileprivate func checkCacheAfter(_ index: Int) {
        let cached = cachedResponses.filter({ $0.index > index }).sorted(by: { $0.index < $1.index })
        for cachedItem in cached {
            if cachedItem.index == itemsCount + collectionCountOffset {
                collection.members?.append(cachedItem.item)
                data.append(cachedItem.item)
            } else {
                while brokenResponses.contains(collectionCountOffset + itemsCount) {
                    collectionCountOffset += 1
                }
                
                if cachedItem.index == itemsCount + collectionCountOffset {
                    collection.members?.append(cachedItem.item)
                    data.append(cachedItem.item)
                } else {
                    break
                }
            }
        }
    }
    
    fileprivate func deleteItem(_ urlString: String) {
        var indexToDelete = -1
        for (index,item) in toDownload!.enumerated() {
            if let m = item as? IIIFManifest, m.id.absoluteString == urlString {
                indexToDelete = index
                break
            } else if let c = item as? IIIFCollection, c.id.absoluteString == urlString {
                indexToDelete = index
                break
            } else if let s = item as? String, s == urlString {
                indexToDelete = index
                break
            }
        }
        
        if indexToDelete >= 0 {
            toDownload!.remove(at: indexToDelete)
        }
    }
    
    func getItemAtPosition(_ i: Int) -> Any? {
        return collection.members?[i]
    }
    
    func selectItemAt(_ index: Int) {
        guard let item = getItemAtPosition(index) else {
            return
        }
        
        AnalyticsUtil.logSelect(item)
        if let m = item as? IIIFManifest {
            delegate?.showViewer(manifest: m)
        } else if let c = item as? IIIFCollection {
            delegate?.showCollection(collection: c)
        }
    }
    
    // must be run from the main thread
    fileprivate func addItem(item: Any) {
        if collection.members == nil {
            collection.members = []
        }
        collection.members?.append(item)
        data.append(item)
    }
    
    // must be run from the main thread
    fileprivate func addItem(item: Any, atIndex index: Int) {
        if collection.members == nil {
            collection.members = []
        }
        
        if index == itemsCount + collectionCountOffset {
            collection.members?.append(item)
            data.append(item)
        } else {
            let cached = cachedResponses.filter({ $0.index < index }).sorted(by: { $0.index < $1.index })
            for cachedItem in cached {
                if cachedItem.index == itemsCount + collectionCountOffset {
                    collection.members?.append(cachedItem.item)
                    data.append(cachedItem.item)
                } else {
                    while brokenResponses.contains(collectionCountOffset + itemsCount) {
                        collectionCountOffset += 1
                    }
                    
                    if cachedItem.index == itemsCount + collectionCountOffset {
                        collection.members?.append(cachedItem.item)
                        data.append(cachedItem.item)
                    } else {
                        break
                    }
                }
            }
            
            if index == itemsCount + collectionCountOffset {
                collection.members?.append(item)
                data.append(item)
            } else {
                cachedResponses.append((index, item))
            }
        }
        
        checkCacheAfter(index)
        
        if toDownload!.isEmpty {
            delegate?.didFinishLoadingData(error: self.loadingError)
        }
    }
    
    func stopLoading() {
        request?.cancel()
        _session?.invalidateAndCancel()
        _session = nil
    }
    
    func beginLoading() {
        delegate?.didStartLoadingData()
        if collection.members == nil && (toDownload == nil || toDownload!.isEmpty) {
            downloadData(collection.id)
        } else if toDownload != nil, !toDownload!.isEmpty {
            loadAllMembers()
        } else {
            delegate?.didFinishLoadingData(error: nil)
        }
    }
    
    func clearData() {
        collection.members = nil
        data.removeAll()
        toDownload = []
        cachedResponses.removeAll()
    }

    func refreshData() {
        stopLoading()
        clearData()
        beginLoading()
    }
}
