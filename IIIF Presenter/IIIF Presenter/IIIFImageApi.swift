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
    
    var minSize: CGSize = CGSize(width: 256, height: 256)
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
        } else if version == 2 {
            return nil
        }
        
        let imageWidth = json["width"] as! Int
        let imageHeight = json["height"] as! Int
        switch version {
        case 1:
            if let size = (json["sizes"] as? [[String:Int]])?.min(by: {a,b in a["width"]! < b["width"]! }) {
                let width = size["width"]!
                let height = size["height"]!
                minSize = CGSize(width: width, height: height)
            } else if let tiles = json["tiles"] as? [String:Any] {
                let tileWidth = tiles["width"] as! Int
                let tileHeight = tiles["height"] as? Int ?? tileWidth
                
                if let scaleFactor = (tiles["scaleFactors"] as? [Int])?.max() {
                    let scaledWidth = imageWidth/scaleFactor
                    let scaledHeight = imageHeight/scaleFactor
                    if scaledWidth > tileWidth || scaledHeight > tileHeight {
                        minSize = CGSize(width: tileWidth, height: tileHeight)
                    } else {
                        minSize = CGSize(width: scaledWidth, height: scaledHeight)
                    }
                } else {
                    minSize = CGSize(width: tileWidth, height: tileHeight)
                }
            }
        case 2:
            if let scaleFactor = (json["scale_factors"] as? [Int])?.max() {
                let scaledWidth = imageWidth/scaleFactor
                let scaledHeight = imageHeight/scaleFactor
                
                if let tileWidth = json["tile_width"] as? Int {
                    let tileHeight = json["tile_height"] as? Int ?? tileWidth
                    if scaledWidth > tileWidth || scaledHeight > tileHeight {
                        minSize = CGSize(width: tileWidth, height: tileHeight)
                    } else {
                        minSize = CGSize(width: scaledWidth, height: scaledHeight)
                    }
                } else {
                    minSize = CGSize(width: scaledWidth, height: scaledHeight)
                }
            } else if let tileWidth = json["tile_width"] as? Int {
                let tileHeight = json["tile_height"] as? Int ?? tileWidth
                minSize = CGSize(width: tileWidth, height: tileHeight)
            }
        default:
            break
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
        
        let size = "\(Int(minSize.width)),\(minSize.width == minSize.height ? "" : String(Int(minSize.height)))"
        let result = id.appending("/full/\(size)/0/\(quality).\(format)")
        log("Thumbnail url: \(result).")
        return result
    }
    
    static func cropImageUrl(urlString: String) -> String {
        if let index = urlString.range(of: "full/full/")?.lowerBound {
            let newRange = Range(uncheckedBounds: (index, urlString.endIndex))
            return urlString.replacingCharacters(in: newRange, with: "info.json")
        }
        return urlString
    }
}
