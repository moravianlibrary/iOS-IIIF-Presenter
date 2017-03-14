//
//  CardViewModel.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 09/03/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

class CardViewModel {
    
    var manifest: IIIFManifest?
    var collection: IIIFCollection?
    
    var delegate: CardDelegate? {
        didSet {
            if delegate != nil {
                self.notifyDelegate()
            } else {
                request?.cancel()
            }
        }
    }
    
    var isLoadingData = false
    fileprivate var wasLoadingData = false
    fileprivate var request: URLSessionDataTask?
    
    static func getModel(_ item: Any, delegate: CardDelegate?=nil) -> CardViewModel? {
        if let m = item as? IIIFManifest {
            return CardViewModel(m, delegate: delegate)
        } else if let c = item as? IIIFCollection {
            return CardViewModel(c, delegate: delegate)
        } else if let s = item as? String, let url = URL(string: s) {
            return CardViewModel(url, delegate: delegate)
        } else {
            return nil
        }
    }
    
    init(_ manifest: IIIFManifest, delegate: CardDelegate?=nil) {
        self.manifest = manifest
        self.delegate = delegate
        if manifest.sequences == nil {
            isLoadingData = true
            wasLoadingData = true
            delegate?.loadingDidStart()
            self.downloadData(manifest.id)
        }
    }
    
    init(_ collection: IIIFCollection, delegate: CardDelegate?=nil) {
        self.collection = collection
        self.delegate = delegate
        if !isCollectionLoaded(collection) {
            isLoadingData = true
            wasLoadingData = true
            delegate?.loadingDidStart()
            self.downloadData(collection.id)
        }
    }
    
    init(_ url: URL, delegate: CardDelegate?=nil) {
        self.delegate = delegate
        isLoadingData = true
        wasLoadingData = true
        delegate?.loadingDidStart()
        self.downloadData(url)
    }
    
    fileprivate func downloadData(_ url: URL) {
        request = URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.isLoadingData = false
            if data != nil,
                let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                
                if let manifest = IIIFManifest(serialization as! [String:Any]) {
                    // copy to propagate change up to the collection it belongs to
                    self.manifest = manifest
                    self.notifyDelegate()
                } else if let collection = IIIFCollection(serialization as! [String:Any]) {
                    self.collection = collection
                    self.notifyDelegate()
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.loadingDidFail()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.loadingDidFail()
                }
            }
        }
        request?.resume()
    }
    
    fileprivate func loadThumbnail() {
        if let urlString = manifest?.thumbnail?.getSingleValue(), let url = URL(string: urlString) {
            loadThumbnail(url)
        } else if let urlString = collection?.thumbnail?.getSingleValue(), let url = URL(string: urlString) {
            loadThumbnail(url)
        } else {
            loadThumbnailAsCanvas()
        }
    }
    
    fileprivate func loadThumbnail(_ url: URL) {
        request = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                if data != nil {
                    self.delegate?.setImage(data: data!)
                } else {
                    self.loadThumbnailAsCanvas()
                }
            }
        })
        request?.resume()
    }
    
    fileprivate func loadThumbnailAsCanvas() {
        if let urlString = manifest?.sequences?.first?.canvases.first?.images?.first?.resource.id,
            let url = CanvasViewModel.getThumbnailUrl(urlString) {
            request = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if data != nil {
                    DispatchQueue.main.async {
                        self.delegate?.setImage(data: data!)
                    }
                }
            })
            request?.resume()
        } else {
            self.delegate?.setImage(data: nil)
        }
    }
    
    // notify delegate with new data
    fileprivate func notifyDelegate() {
        guard delegate != nil, !isLoadingData else {
            // no need for any action when there is no delegate anymore
            return
        }
        
        guard Thread.current.isMainThread else {
            // ensure calling delegate on the main thread
            DispatchQueue.main.async {
                self.notifyDelegate()
            }
            return
        }
        
        if collection != nil {
            if wasLoadingData {
                delegate?.replaceItem(item: collection!)
                wasLoadingData = false
            }
            delegate?.setTitle(title: collection!.title.getSingleValue()!)
            delegate?.setDate(date: collection!.date)
        } else if manifest != nil {
            if wasLoadingData {
                delegate?.replaceItem(item: manifest!)
                wasLoadingData = false
            }
            delegate?.setTitle(title: manifest!.title.getSingleValue()!)
            delegate?.setDate(date: manifest!.date)
        }
        loadThumbnail()
    }
    
    fileprivate func isCollectionLoaded(_ c: IIIFCollection) -> Bool {
        return collection?.members != nil
    }
}
