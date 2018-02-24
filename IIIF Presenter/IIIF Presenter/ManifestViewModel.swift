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
                imageUtil.stopLoading()
            }
        }
    }

    var metaInfoCount: Int {
        return manifestInfo.count
    }

    fileprivate var manifestInfo = [(String, Any)]()
    fileprivate var imageUtil = ImageUtil()

    init(_ manifest: IIIFManifest, delegate: CardDelegate?=nil) {
        self.manifest = manifest
        self.delegate = delegate

        if let value = manifest.description {
            manifestInfo.append((NSLocalizedString("description", comment: ""), value))
        }
        if let value = manifest.attribution {
            manifestInfo.append((NSLocalizedString("attribution", comment: ""), value))
        }
        if let value = manifest.license {
            manifestInfo.append((NSLocalizedString("license", comment: ""), value))
        }
        if let value = manifest.viewingDirection {
            manifestInfo.append((NSLocalizedString("view_direction", comment: ""), value))
        }
        if let value = manifest.viewingHint {
            manifestInfo.append((NSLocalizedString("view_hint", comment: ""), value))
        }
        if let value = manifest.date {
            manifestInfo.append((NSLocalizedString("date", comment: ""), value))
        }
        if let value = manifest.related {
            manifestInfo.append((NSLocalizedString("related", comment: ""), value))
        }
        if let value = manifest.rendering {
            manifestInfo.append((NSLocalizedString("rendering", comment: ""), value))
        }
        if let value = manifest.service {
            manifestInfo.append((NSLocalizedString("service", comment: ""), value))
        }
        if let value = manifest.seeAlso {
            manifestInfo.append((NSLocalizedString("see_also", comment: ""), value))
        }
        if let value = manifest.within {
            manifestInfo.append((NSLocalizedString("within", comment: ""), value))
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
            return val.getValueTranslated(lang: lang) ?? val.getSingleValue()
        } else if let val = item as? String {
            return val
        } else if let val = item as? Date {
            return Constants.dateFormatter.string(from: val)
        }
        return nil
    }

    fileprivate func loadThumbnail() {
        delegate?.loadingDidStart()
        imageUtil.getFirstImage(manifest) { (image) in
            DispatchQueue.main.async {
                self.delegate?.set(image: image)
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

        delegate?.set(title: manifest.title.getSingleValue()!)
        delegate?.set(date: manifest.date)
        loadThumbnail()
    }
}
