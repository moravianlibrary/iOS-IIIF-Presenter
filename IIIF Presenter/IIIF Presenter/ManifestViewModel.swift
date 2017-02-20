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
    
    func showDetail() {
        listDelegate?.showDetail(manifest: manifest)
    }
    
    fileprivate func downloadManifestData(_ url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if data != nil,
                let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments),
                let manifest = IIIFManifest(serialization as! [String:Any]) {
                
                self.manifest.title = manifest.title
                self.manifest.sequences = manifest.sequences
                self.notifyDelegate()
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
    
    fileprivate func notifyDelegate() {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.notifyDelegate()
            }
            return
        }
        
        delegate?.setTitle(title: manifest.title.getValueList()!.first!)
        getThumbnail()
    }
}
