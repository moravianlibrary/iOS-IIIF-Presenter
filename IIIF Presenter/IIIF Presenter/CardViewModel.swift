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
                imageUtil.stopLoading()
            }
        }
    }
    
    fileprivate var imageUtil = ImageUtil()
    
    static func getModel(_ item: Any, delegate: CardDelegate?=nil) -> CardViewModel? {
        if let m = item as? IIIFManifest {
            return CardViewModel(m, delegate: delegate)
        } else if let c = item as? IIIFCollection {
            return CardViewModel(c, delegate: delegate)
        } else {
            return nil
        }
    }
    
    init(_ manifest: IIIFManifest, delegate: CardDelegate?=nil) {
        self.manifest = manifest
        self.delegate = delegate
    }
    
    init(_ collection: IIIFCollection, delegate: CardDelegate?=nil) {
        self.collection = collection
        self.delegate = delegate
    }
    
    fileprivate func loadThumbnail() {
        delegate?.loadingDidStart()
        imageUtil.getFirstImage(manifest ?? collection) { (image) in
            DispatchQueue.main.async {
                self.delegate?.set(image: image)
            }
        }
    }
    
    // notify delegate with new data
    fileprivate func notifyDelegate() {
        guard delegate != nil /*, !isLoadingData */ else {
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
            delegate?.set(title: collection!.title.getSingleValue()!)
            delegate?.set(date: collection!.date)
            delegate?.set(type: "Collection")
        } else if manifest != nil {
            delegate?.set(title: manifest!.title.getSingleValue()!)
            delegate?.set(date: manifest!.date)
            delegate?.set(type: "Manifest")
        }
        loadThumbnail()
    }
    
    fileprivate func isCollectionLoaded(_ c: IIIFCollection) -> Bool {
        return collection?.members != nil
    }
}
