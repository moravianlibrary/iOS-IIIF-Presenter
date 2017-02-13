//
//  AnnotationList.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct AnnotationList {

    static let type = "sc:AnnotationList"
    
    // required
    let resources: [Annotation]
    
    // should have
    
    // optional
    let next: String?
    let previous: String?
    let startIndex: Int?
    
    
    init?(_ json: [String:Any]) {
        
        // required
        resources = []
        
        // optional
        next = nil
        previous = nil
        startIndex = nil
    }
}
