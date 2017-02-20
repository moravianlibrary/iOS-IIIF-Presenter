//
//  IIIFRange.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct IIIFRange {

    static let type = "sc:Range"
    
    // required
    let id: URL
    let title: MultiProperty
    
    // should have
    
    // optional
    let metadata: MultiProperty?
    let description: MultiProperty?
    let thumbnail: MultiProperty?
    let attribution: MultiProperty?
    let license: MultiProperty?
    let logo: MultiProperty?
    let viewingDirection: String?
    let viewingHint: MultiProperty?
    let related: MultiProperty?
    let rendering: MultiProperty?
    let service: MultiProperty?
    let seeAlso: MultiProperty?
    let within: MultiProperty?
    let startCanvas: String?
    let contentLayer: String?
    
    
    init?(_ json: [String:Any]) {
        
        guard let idString = json["@id"] as? String,
            let id = URL(string: idString),
            let title = MultiProperty(json["label"]) else {
                return nil
        }
        
        self.id = id
        self.title = title
        
        // optional fields
        description = MultiProperty(json["description"])
        metadata = MultiProperty(json["metadata"])
        thumbnail = MultiProperty(json["thumbnail"])
        attribution = MultiProperty(json["attribution"])
        license = MultiProperty(json["license"])
        logo = MultiProperty(json["logo"])
        viewingDirection = json["viewingDirection"] as? String
        viewingHint = MultiProperty(json["viewingHint"])
        related = MultiProperty(json["related"])
        rendering = MultiProperty(json["rendering"])
        service = MultiProperty(json["service"])
        seeAlso = MultiProperty(json["seeAlso"])
        within = MultiProperty(json["within"])
        startCanvas = json["startCanvas"] as? String
        contentLayer = json["contentLayer"] as? String
    }
}
