//
//  Metadata.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 03/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct Metadata {
    
    let key: String
    let value: String
    let translations: [String:String]

    init(_ json: [String: Any]) {
        
        key = ""
        value = ""
        translations = [:]
    }
}
