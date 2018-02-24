//
//  IIIFCanvas.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation


struct IIIFCanvas {

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
    let metadata: Metadata?
    let attribution: MultiProperty?
    let license: MultiProperty?
    let logo: MultiProperty?
    let viewingHint: MultiProperty?
    let related: MultiProperty?
    let rendering: MultiProperty?
    let service: MultiProperty?
    let seeAlso: MultiProperty?
    let within: MultiProperty?
    let images: [IIIFAnnotation]?
    let otherContent: [IIIFAnnotationList]?


    init?(_ json: [String: Any]) {

        guard let idString = json["@id"] as? String,
            let id = URL(string: idString),
            let title = MultiProperty(json["label"]),
            let height = json["height"] as? Int,
            let width = json["width"] as? Int else {
                return nil
        }

        self.id = id
        self.title = title
        self.height = height
        self.width = width

        // optional fields
        description = MultiProperty(json["description"])
        metadata = Metadata(json["metadata"])
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

        if let imgs = json["images"] as? [[String: Any]] {
            var array = [IIIFAnnotation]()
            for img in imgs {
                if let a = IIIFAnnotation(img) {
                    array.append(a)
                }
            }
            images = array
        } else {
            images = nil
        }

        if let _ = json["otherContent"] as? [[String: Any]] {
            // Annotation List
            otherContent = nil
        } else {
            otherContent = nil
        }
    }
}
