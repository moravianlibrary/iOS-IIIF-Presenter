//
//  Collection.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct Collection {

    static let type = "sc:Collection"
    
    // required
    let id: URL
    let title: MultiProperty
    let manifests: [Manifest]
    
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
        
        id = URL(string: json["@id"] as! String)!
        title = MultiProperty(json["label"])!
        var array = [Manifest]()
        for item in json["manifests"] as! [[String:Any]] {
            if let m = Manifest(item) {
                array.append(m)
            }
        }
        manifests = array
        
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
    
    static func createCollectionWith(_ manifests: [Manifest]) -> Collection {
        return Collection(manifests: manifests)
    }
    
    fileprivate init(manifests: [Manifest]) {
        id = URL(string: "www.google.com")!
        title = MultiProperty(["":"Title"])!
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
