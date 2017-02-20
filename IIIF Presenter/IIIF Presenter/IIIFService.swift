//
//  IIIFService.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct IIIFService {

    let id: String
    let profile: String?
    
    
    init?(_ json: [String:Any]?) {
        
        guard let json = json,
            let id = json["@id"] as? String else {
            return nil
        }
        
        self.id = id
        profile = json["profile"] as? String
    }
}
