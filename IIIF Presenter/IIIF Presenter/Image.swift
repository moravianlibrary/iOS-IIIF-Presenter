//
//  Image.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct Image {
    
    // required
    let id: String
    
    // optional
    let format: String?
    let width: Int?
    let height: Int?
    let service: Service?
    
    
    init?(_ json: [String:Any]) {
        
        id = json["@id"] as! String
        
        format = json["format"] as? String
        width = json["width"] as? Int
        height = json["height"] as? Int
        service = Service(json["service"] as? [String:Any])
    }
}
