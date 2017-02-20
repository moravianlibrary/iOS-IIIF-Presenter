//
//  ManifestViewModel.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

class ManifestViewModel {
    
    var manifest: Manifest
    var delegate: CardDelegate? {
        didSet {
            self.notifyDelegate()
        }
    }
    
    init(_ manifest: Manifest) {
        self.manifest = manifest
        if manifest.sequences == nil {
            self.downloadManifestData(manifest.id)
        }
    }
    
    fileprivate func downloadManifestData(_ url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if data != nil,
                let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments),
                let manifest = Manifest(serialization as! [String:Any]) {
                
                self.manifest = manifest
                DispatchQueue.main.async {
                    self.notifyDelegate()
                }
            }
        }.resume()
    }
    
    fileprivate func getThumbnail() {
        if let urlString = manifest.thumbnail?.getValueList()?.first, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                self.delegate?.setImage(data: data!)
            }).resume()
        } else {
            self.delegate?.setImage(data: nil)
        }
    }
    
    fileprivate func notifyDelegate() {
        delegate?.setTitle(title: manifest.title.getValueList()!.first!)
        getThumbnail()
    }
}
