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
    
    var metaInfoCount: Int {
        return manifestInfo.count
    }
    
    fileprivate var manifestInfo = [(String,Any)]()
    fileprivate var request: URLSessionDataTask?
    fileprivate var imageUtil = ImageUtil()
    
    init(_ manifest: IIIFManifest, delegate: CardDelegate?=nil) {
        self.manifest = manifest
        self.delegate = delegate
        
        if let value = manifest.description {
            manifestInfo.append(("Description", value))
        }
        if let value = manifest.attribution {
            manifestInfo.append(("Attribution", value))
        }
        if let value = manifest.license {
            manifestInfo.append(("License", value))
        }
        if let value = manifest.viewingDirection {
            manifestInfo.append(("ViewingDirection", value))
        }
        if let value = manifest.viewingHint {
            manifestInfo.append(("ViewingHint", value))
        }
        if let value = manifest.date {
            manifestInfo.append(("Date", value))
        }
        if let value = manifest.related {
            manifestInfo.append(("Related", value))
        }
        if let value = manifest.rendering {
            manifestInfo.append(("Rendering", value))
        }
        if let value = manifest.service {
            manifestInfo.append(("Service", value))
        }
        if let value = manifest.seeAlso {
            manifestInfo.append(("SeeAlso", value))
        }
        if let value = manifest.within {
            manifestInfo.append(("Within", value))
        }
        
    }
    
    func getMetaInfoKey(at index: Int) -> String? {
        guard case 0..<metaInfoCount = index else {
            return nil
        }
        
        let (key, _) = manifestInfo[index]
        return key
    }
    
    func getMetaInfo(at index: Int, forLanguage lang: String) -> String? {
        guard case 0..<metaInfoCount = index else {
            return nil
        }
        
        let (_, item) = manifestInfo[index]
        if let val = item as? MultiProperty {
            return val.getValueTranslated(lang: lang) ?? val.getValueTranslated(lang: "en") ?? val.getSingleValue()
        } else if let val = item as? String {
            return val
        } else if let val = item as? Date {
            return Constants.dateFormatter.string(from: val)
        }
        return nil
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
