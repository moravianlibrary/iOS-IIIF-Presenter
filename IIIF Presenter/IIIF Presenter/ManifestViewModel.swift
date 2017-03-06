//
//  ManifestViewModel.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

class ManifestViewModel {
    
    var manifest: IIIFManifest
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
    fileprivate var request: URLSessionDataTask?
    
    init(_ manifest: IIIFManifest, delegate: CardDelegate?=nil) {
        self.manifest = manifest
        self.delegate = delegate
        if manifest.sequences == nil {
            isLoadingData = true
            delegate?.loadingDidStart()
            self.downloadManifestData(manifest.id)
        }
    }
    
    fileprivate func downloadManifestData(_ url: URL) {
        request = URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.isLoadingData = false
            if data != nil,
                let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments),
                let manifest = IIIFManifest(serialization as! [String:Any]) {
                
                // copy to propagate change up to the collection it belongs to
                self.manifest.copy(manifest)
                self.notifyDelegate()
            } else {
                DispatchQueue.main.async {
                    self.delegate?.loadingDidFail()
                }
            }
        }
        request?.resume()
    }
    
    fileprivate func loadThumbnail() {
        if let urlString = manifest.thumbnail?.getSingleValue(), let url = URL(string: urlString) {
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
        } else {
            loadThumbnailAsCanvas()
        }
    }
    
    fileprivate func loadThumbnailAsCanvas() {
        if let urlString = manifest.sequences?.first?.canvases.first?.images?.first?.resource.id,
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
        
        delegate?.setTitle(title: manifest.title.getSingleValue()!)
        delegate?.setDate(date: manifest.date)
        loadThumbnail()
    }
}
