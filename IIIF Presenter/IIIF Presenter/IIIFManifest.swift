//
//  IIIFManifest.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

class IIIFManifest {

    static let type = "sc:Manifest"
    
    // required fields
    let id: URL
    var title: MultiProperty
    var sequences: [IIIFSequence]?
    
    // should have
    let metadata: MultiProperty?
    let description: MultiProperty?
    let thumbnail: MultiProperty?
    
    // optional fields
    let attribution: MultiProperty?
    let license: MultiProperty?
    let logo: MultiProperty?
    let viewingDirection: String?
    let viewingHint: MultiProperty?
    let date: Date?
    let related: MultiProperty?
    let rendering: MultiProperty?
    let service: MultiProperty?
    let seeAlso: MultiProperty?
    let within: MultiProperty?
    
    init?(_ json: [String: Any]) {
        
        guard let idString = json["@id"] as? String,
            let id = URL(string: idString),
            let title = MultiProperty(json["label"]) else {
                return nil
        }
        
        self.id = id
        self.title = title
        
        // may be nil if present only as a reference
        if let seq = json["sequences"] as? [[String:Any]] {
            var array = [IIIFSequence]()
            for s in seq {
                if let seq = IIIFSequence(s) {
                    array.append(seq)
                }
            }
            sequences = array
        }
        
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
        
        if let dateString = json["navDate"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DDThh:mm:ssZ"
            date = formatter.date(from: dateString)
        } else {
            date = nil
        }
    }
}
