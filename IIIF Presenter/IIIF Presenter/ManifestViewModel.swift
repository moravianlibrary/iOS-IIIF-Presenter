//
//  ManifestViewModel.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct ManifestViewModel {
    
    let manifest: Manifest
    var delegate: CardDelegate? {
        didSet {
            delegate?.setTitle(title: manifest.title.getValueList()!.first!)
            getThumbnail()
        }
    }
    
    init(_ manifest: Manifest) {
        self.manifest = manifest
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
}
