//
//  Sequence.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct Sequence {
    
    static let type = "sc:Sequence"

    // required fields
    let canvases: [Canvas]
    
    // should have
    
    // optional fields
    let id: String?
    let title: MultiProperty?
    let description: MultiProperty?
    let thumbnail: MultiProperty?
    let metadata: MultiProperty?
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
    
    init?(_ json: [String:Any]) {
        
        id = json["@id"] as? String
        var array = [Canvas]()
        for obj in json["canvases"] as! [[String:Any]] {
            if let c = Canvas(obj) {
                array.append(c)
            }
        }
        canvases = array
        
        // optional fields
        title = MultiProperty(json["label"])
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
    }
}
