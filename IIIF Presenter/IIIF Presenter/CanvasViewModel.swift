//
//  CanvasViewModel.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 20/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

class CanvasViewModel {
    
    let canvas: IIIFCanvas
    var delegate: CanvasThumbnailDelegate? {
        didSet {
            guard delegate != nil else {
                request?.cancel()
                return
            }
            
            notifyDelegate()
        }
    }
    
    fileprivate var request: URLSessionDataTask?
    
    init(_ canvas: IIIFCanvas) {
        self.canvas = canvas
    }
    
    fileprivate func loadThumbnail() {
        if let imageUrl = canvas.images?.first?.resource.service?.id, let url = CanvasViewModel.getThumbnailUrl(imageUrl) {
            request = URLSession.shared.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    self.delegate?.showImage(data: data)
                }
            }
            request?.resume()
        } else {
            self.delegate?.showImage(data: nil)
        }
    }
    
    static func getThumbnailUrl(_ url: String) -> URL? {
        var imageUrl = url
        if imageUrl.lowercased().hasSuffix("default.jpg") {
            let range = imageUrl.range(of: "full", options: .backwards, range: nil, locale: nil)!
            imageUrl.replaceSubrange(range, with: "100,")
        } else if imageUrl.lowercased().hasSuffix("info.json") {
            imageUrl = imageUrl.replacingOccurrences(of: "info.json", with: "full/100,/0/default.jpg", options: .caseInsensitive, range: nil)
        } else {
            imageUrl.append("/full/100,/0/default.jpg")
        }
        return URL(string: imageUrl)
    }
    
    fileprivate func notifyDelegate() {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.notifyDelegate()
            }
            return
        }
        
        let title = canvas.title.getValueTranslated(lang: Constants.lang, defaultLanguage: "en") ?? canvas.title.getSingleValue()
        delegate?.showTitle(title)
        loadThumbnail()
    }
}
