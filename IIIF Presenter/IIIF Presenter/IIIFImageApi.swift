//
//  IIIFImageApi.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 29/04/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

struct IIIFImageApi {

    static let context = ["http://library.stanford.edu/iiif/image-api/1.1/context.json", "http://iiif.io/api/image/2/context.json"]
    static let type = "iiif:Image"
    
    let id: String
    let version: Int
    
    var minSize: CGSize?
    var formats: [String]?
    var qualities: [String]?
    
    init?(_ json: [String:Any]) {
        guard let id = json["@id"] as? String,
            let context = json["@context"] as? String,
            IIIFImageApi.context.contains(context) else {
                return nil
        }
        
        if let type = json["@type"] as? String, type != IIIFImageApi.type {
            return nil
        }
        
        self.id = id
        self.version = IIIFImageApi.context.index(of: context)! + 1
        
        if let profile = json["profile"] {
            if let value = profile as? [Any] {
                for case let val as [String:Any] in value {
                    if let formats = val["formats"] as? [String] {
                        self.formats = formats
                    }
                    if let qualities = val["qualities"] as? [String] {
                        self.qualities = qualities
                    }
                }
            } else if let value = profile as? [String:Any] {
                if let formats = value["formats"] as? [String] {
                    self.formats = formats
                }
                if let qualities = value["qualities"] as? [String] {
                    self.qualities = qualities
                }
            }
        }
    }
    
    func getThumbnailUrl() -> String {
        let format: String
        if formats != nil {
            format = formats!.contains("jpg") ? "jpg" : formats!.first!
        } else {
            format = "jpg"
        }
        
        let quality: String
        if qualities != nil {
            if version == 1 {
                quality = qualities!.contains("native") ? "native" : qualities!.first!
            } else {
                quality = qualities!.contains("default") ? "default" : qualities!.first!
            }
        } else {
            quality = version == 1 ? "native" : "default"
        }
        
        let result = id.appending("/full/\(Int(minSize?.width ?? 256)),/0/\(quality).\(format)")
        print("Thumbnail url: \(result).")
        return result
    }
}
