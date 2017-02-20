//
//  IIIFImage.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct IIIFImage {
    
    // required
    let id: String
    
    // optional
    let format: String?
    let width: Int?
    let height: Int?
    let service: IIIFService?
    
    
    init?(_ json: [String:Any]) {
        
        guard let id = json["@id"] as? String else {
            return nil
        }
        
        self.id = id
        
        format = json["format"] as? String
        width = json["width"] as? Int
        height = json["height"] as? Int
        service = IIIFService(json["service"] as? [String:Any])
    }
}
