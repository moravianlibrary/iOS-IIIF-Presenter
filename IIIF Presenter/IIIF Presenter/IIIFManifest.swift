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
    var metadata: Metadata?
    var description: MultiProperty?
    var thumbnail: IIIFImage?
    
    // optional fields
    var attribution: MultiProperty?
    var license: MultiProperty?
    var logo: MultiProperty?
    var viewingDirection: String?
    var viewingHint: MultiProperty?
    var date: Date?
    var related: MultiProperty?
    var rendering: MultiProperty?
    var service: MultiProperty?
    var seeAlso: MultiProperty?
    var within: MultiProperty?
    
    init?(_ json: [String: Any]) {
        
        guard json["@type"] as? String == IIIFManifest.type,
            let idString = json["@id"] as? String,
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
        if let thumbnail = json["thumbnail"] as? [String:Any] {
            self.thumbnail = IIIFImage(thumbnail)
        }
        
        description = MultiProperty(json["description"])
        metadata = Metadata(json["metadata"])
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
        }
    }
    
    init?(id: String?) {
        guard id != nil, let url = URL(string: id!) else {
            return nil
        }
        
        self.id = url
        self.title = MultiProperty("...")!
    }
}

extension IIIFManifest: Equatable {
    
    public static func ==(lhs: IIIFManifest, rhs: IIIFManifest) -> Bool {
        return lhs.id.absoluteString == rhs.id.absoluteString
    }
}
