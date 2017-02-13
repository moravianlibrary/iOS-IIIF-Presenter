//
//  Annotation.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct Annotation {

    static let type = "oa:Annotation"
    static let motivationImage = "sc:painting"
    
    // required
    let motivation: String
    let resource: Image
    let on: String
    
    // optional
    let id: URL?
    
    
    init?(_ json: [String:Any]) {
        
        motivation = json["motivation"] as! String
        on = json["on"] as! String
        resource = Image(json["resource"] as! [String:Any])!
        
        if let value = json["@id"] as? String {
            id = URL(string: value)
        } else {
            id = nil
        }
    }
}
