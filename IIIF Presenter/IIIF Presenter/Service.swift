//
//  Service.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct Service {

    let id: String
    let profile: String?
    
    
    init?(_ json: [String:Any]?) {
        
        guard let json = json else {
            return nil
        }
        
        id = json["@id"] as! String
        profile = json["profile"] as? String
    }
}
