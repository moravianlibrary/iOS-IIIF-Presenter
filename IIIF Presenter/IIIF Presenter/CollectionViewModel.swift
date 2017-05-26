//
//  CollectionViewModel.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

class CollectionViewModel {
    
    var collection: IIIFCollection
    var delegate: CardListDelegate?
    var loadingError: NSError?
    
    var itemsCount: Int {
        return collection.members?.count ?? 0
    }
    
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
            delegate?.didStartLoadingData()
            downloadMember()
        }
    }
    
    fileprivate init(_ urlString: String, _ delegate: CardListDelegate?, _ items: [Any]?) {
        let url = URL(string: urlString)!
        collection = IIIFCollection.createCollectionWith(url, members: items)
        self.delegate = delegate
        if let url = URL(string: urlString) {
//            self.downloadData(url)
        } else {
            log("Is not valid url: \(urlString).")
        }
    }
    
    
    fileprivate func downloadData(_ url: URL) {
        delegate?.didStartLoadingData()
        request = session.dataTask(with: url, completionHandler: { (data, response, error) in
            var err: NSError? = nil
            if (error as NSError?)?.code == NSURLErrorCancelled {
                return
            } else if data != nil,
                let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                if let c = IIIFCollection(serialization as! [String:Any]) {
                    self.collection = c
                    self.toDownload = self.collection.members
                    self.collection.members = nil
                } else if let m = IIIFManifest(serialization as! [String:Any]) {
                    self.collection.members!.insert(m, at: 0)
                } else {
                    err = NSError(domain: "cz.mzk", code: 102, userInfo: [NSLocalizedDescriptionKey: ["en":"Parsing error", "cz":"Chyba parsovani"]])
                    log("Unknown IIIF structure at \(url.absoluteString).")
                }
            } else if error != nil {
                err = error as NSError?
                log("Request error from \(url.absoluteString).")
            } else {
                err = NSError(domain: "cz.mzk", code: 101, userInfo: [NSLocalizedDescriptionKey: ["en":"Parsing error", "cz":"Chyba parsovani"]])
                log("Parsing error from \(url.absoluteString).")
            }
            
            self.loadingError = err
            self.downloadMember()
        })
        request?.resume()
    }
    
    fileprivate func downloadMember() {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.downloadMember()
            }
            return
        }
        
        guard toDownload != nil, !toDownload!.isEmpty else {
            delegate?.didFinishLoadingData(error: self.loadingError)
            return
        }
        
        let item = toDownload?.removeFirst()
        if let m = item as? IIIFManifest {
            if m.sequences == nil {
                handleMember(url: m.id)
            } else {
                addItem(item: m)
                downloadMember()
            }
        } else if let c = item as? IIIFCollection {
            if c.members == nil {
                handleMember(url: c.id)
            } else {
                addItem(item: c)
                downloadMember()
            }
        } else if let s = item as? String, let url = URL(string: s) {
            handleMember(url: url)
        } else {
            log("Found any other structure.")
            downloadMember()
        }
    }
    
    fileprivate func handleMember(url: URL) {
        request = session.dataTask(with: url, completionHandler: { (data, response, error) in
            log("Finish \(url.absoluteString)")
            if (error as NSError?)?.code == NSURLErrorCancelled {
                return
            }
            
            if data != nil, let serialized = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                DispatchQueue.main.async {
                    let json = serialized as! [String:Any]
                    if let c = IIIFCollection(json) {
                        self.addItem(item: c)
                    } else if let m = IIIFManifest(json) {
                        self.addItem(item: m)
                    }
                }
            }
            
            self.downloadMember()
        })
        log("Start \(url.absoluteString)")
        request?.resume()
    }
    
    func getItemAtPosition(_ i: Int) -> Any {
        return collection.members![i]
    }
    
    func selectItemAt(_ index: Int) {
        let item = getItemAtPosition(index)
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
        delegate?.addDataItem()
    }
    
    func stopLoading() {
        request?.cancel()
    }
    
    func beginLoading() {
        delegate?.didStartLoadingData()
        if collection.members == nil && (toDownload == nil || toDownload!.isEmpty) {
            downloadData(collection.id)
        } else if toDownload != nil, !toDownload!.isEmpty {
            downloadMember()
        } else {
            delegate?.didFinishLoadingData(error: nil)
        }
    }
}
