//
//  Canvas.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct Canvas {

    static let type = "sc:Canvas"
    
    // required fields
    let id: URL
    let title: MultiProperty
    let height: Int
    let width: Int
    
    // should have
    
    // optional fields
    let description: MultiProperty?
    let thumbnail: MultiProperty?
    let metadata: MultiProperty?
    let attribution: MultiProperty?
    let license: MultiProperty?
    let logo: MultiProperty?
    let viewingHint: MultiProperty?
    let related: MultiProperty?
    let rendering: MultiProperty?
    let service: MultiProperty?
    let seeAlso: MultiProperty?
    let within: MultiProperty?
    let images: [Annotation]?
    let otherContent: [AnnotationList]?
    
    
    init?(_ json: [String: Any]) {
        
        id = URL(string: json["@id"] as! String)!
        title = MultiProperty(json["label"])!
        height = json["height"] as! Int
        width = json["width"] as! Int
        
        // optional fields
        description = MultiProperty(json["description"])
        metadata = MultiProperty(json["metadata"])
        thumbnail = MultiProperty(json["thumbnail"])
        attribution = MultiProperty(json["attribution"])
        license = MultiProperty(json["license"])
        logo = MultiProperty(json["logo"])
        viewingHint = MultiProperty(json["viewingHint"])
        related = MultiProperty(json["related"])
        rendering = MultiProperty(json["rendering"])
        service = MultiProperty(json["service"])
        seeAlso = MultiProperty(json["seeAlso"])
        within = MultiProperty(json["within"])
        
        if let imgs = json["images"] as? [[String:Any]] {
            var array = [Annotation]()
            for img in imgs {
                if let a = Annotation(img) {
                    array.append(a)
                }
            }
            images = array
        } else {
            images = nil
        }
        
        if let other = json["otherContent"] as? [[String:Any]] {
            // Annotation List
            otherContent = nil
        } else {
            otherContent = nil
        }
    }
}
