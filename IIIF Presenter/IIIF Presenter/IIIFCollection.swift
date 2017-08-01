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
    var title: MultiProperty
    
    // must have one of manifests, collecions or members
    // if not present than the collection needs to be loaded
    var members: Array<Any>?
    
    // should have
    var metadata: Metadata?
    var description: MultiProperty?
    var thumbnail: IIIFImage?
    
    // optional
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
    var first: String?
    var last: String?
    var total: Int?
    var next: String?
    var previous: String?
    var startIndex: Int?
    
    
    static func createCollectionWith(_ url: URL, members: [Any]?) -> IIIFCollection {
        return IIIFCollection(url: url, members: members)
    }
    
    
    init?(_ json: [String:Any]) {
        
        guard json["@type"] as? String == IIIFCollection.type,
            let idString = json["@id"] as? String,
            let id = URL(string: idString),
            let title = MultiProperty(json["label"]) else {
                return nil
        }
        
        var array = [Any]()
        if let members = json["members"] as? [[String:Any]] {
            for item in members {
                if let c = IIIFCollection(item) {
                    array.append(c)
                } else if let m = IIIFManifest(item) {
                    array.append(m)
                }
            }
        }
        if let collections = json["collections"] as? [[String:Any]] {
            for item in collections {
                if let c = IIIFCollection(item) {
                    array.append(c)
                }
            }
        }
        if let manifests = json["manifests"] as? [[String:Any]] {
            for item in manifests {
                if let m = IIIFManifest(item) {
                    array.append(m)
                }
            }
        }
        if !array.isEmpty {
            self.members = array
        }
        
        self.id = id
        self.title = title
        
        // should have
        metadata = Metadata(json["metadata"])
        description = MultiProperty(json["description"])
        
        if let thumbnail = json["thumbnail"] as? [String:Any] {
            self.thumbnail = IIIFImage(thumbnail)
        }
        
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
    
    init?(id: String?) {
        guard id != nil, let url = URL(string: id!) else {
            return nil
        }
        
        self.id = url
        self.title = MultiProperty("...")!
    }
    
    fileprivate init(url: URL, members: [Any]?) {
        id = url
        title = MultiProperty("Collection of action extension")!
        self.members = members
        
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


extension IIIFCollection: Equatable {
    
    public static func ==(lhs: IIIFCollection, rhs: IIIFCollection) -> Bool {
        return lhs.id.absoluteString == rhs.id.absoluteString
    }
}
