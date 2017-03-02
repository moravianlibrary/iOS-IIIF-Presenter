//
//  IIIFCollection.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct IIIFCollection {

    static let type = "sc:Collection"
    
    // required
    let id: URL
    let title: MultiProperty
    var manifests: [IIIFManifest]
    
    // should have
    let metadata: MultiProperty?
    let description: MultiProperty?
    let thumbnail: MultiProperty?
    
    // optional
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
    let first: String?
    let last: String?
    let total: Int?
    let next: String?
    let previous: String?
    let startIndex: Int?
    
    
    init?(_ json: [String:Any]) {
        
        guard let idString = json["@id"] as? String,
            let id = URL(string: idString),
            let title = MultiProperty(json["label"]),
            let manifests = json["manifests"] as? [[String:Any]] else {
                return nil
        }
        
        var array = [IIIFManifest]()
        for item in manifests {
            if let m = IIIFManifest(item) {
                array.append(m)
            }
        }
        
        self.id = id
        self.title = title
        self.manifests = array
        
        // should have
        metadata = MultiProperty(json["metadata"])
        description = MultiProperty(json["description"])
        thumbnail = MultiProperty(json["thumbnail"])
        
        // optional fields
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
        first = json["first"] as? String
        last = json["last"] as? String
        total = json["total"] as? Int
        next = json["next"] as? String
        previous = json["prev"] as? String
        startIndex = json["startIndex"] as? Int
        
        if let dateString = json["navDate"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DDThh:mm:ssZ"
            date = formatter.date(from: dateString)
        } else {
            date = nil
        }
    }
    
    static func createCollectionWith(_ manifests: [IIIFManifest]) -> IIIFCollection {
        return IIIFCollection(manifests: manifests)
    }
    
    fileprivate init(manifests: [IIIFManifest]) {
        id = URL(string: "www.google.com")!
        title = MultiProperty("Title")!
        self.manifests = manifests
        
        metadata = nil
        description = nil
        thumbnail = nil
        attribution = nil
        license = nil
        logo = nil
        viewingDirection = nil
        viewingHint = nil
        related = nil
        rendering = nil
        service = nil
        seeAlso = nil
        within = nil
        first = nil
        last = nil
        total = nil
        next = nil
        previous = nil
        startIndex = nil
        date = nil
    }
}
