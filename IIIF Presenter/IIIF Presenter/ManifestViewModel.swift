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
    var listDelegate: CardListDelegate?
    var delegate: CardDelegate? {
        didSet {
            self.notifyDelegate()
        }
    }
    
    init(_ manifest: IIIFManifest, listDelegate: CardListDelegate?=nil) {
        self.manifest = manifest
        self.listDelegate = listDelegate
        if manifest.sequences == nil {
            self.downloadManifestData(manifest.id)
        }
    }
    
    fileprivate func downloadManifestData(_ url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if data != nil,
                let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments),
                let manifest = IIIFManifest(serialization as! [String:Any]) {
                
                self.manifest.title = manifest.title
                self.manifest.sequences = manifest.sequences
                self.notifyDelegate()
            } else {
                DispatchQueue.main.async {
                    self.delegate?.loadingDidFail()
                }
            }
        }.resume()
    }
    
    fileprivate func getThumbnail() {
        if let urlString = manifest.thumbnail?.getValueList()?.first, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if data != nil {
                    DispatchQueue.main.async {
                        self.delegate?.setImage(data: data!)
                    }
                }
            }).resume()
        } else {
            self.delegate?.setImage(data: nil)
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
        
        delegate?.setTitle(title: manifest.title.getValueList()!.first!)
        getThumbnail()
    }
}
