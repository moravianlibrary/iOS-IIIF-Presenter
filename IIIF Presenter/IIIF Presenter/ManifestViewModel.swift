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
                imageUtil.stopLoading()
            }
        }
    }
    
    fileprivate var request: URLSessionDataTask?
    fileprivate var imageUtil = ImageUtil()
    
    init(_ manifest: IIIFManifest, delegate: CardDelegate?=nil) {
        self.manifest = manifest
        self.delegate = delegate
    }
    
    fileprivate func loadThumbnail() {
        delegate?.loadingDidStart()
        imageUtil.getFirstImage(manifest) { (data) in
            DispatchQueue.main.async {
                self.delegate?.setImage(data: data)
            }
        }
    }
    
    // notify delegate with new data
    fileprivate func notifyDelegate() {
        guard delegate != nil else {
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
