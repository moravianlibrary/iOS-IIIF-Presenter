//
//  IIIFAnnotation.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation


struct IIIFAnnotation {

    static let type = "oa:Annotation"
    static let motivationImage = "sc:painting"

    // required
    let motivation: String
    let resource: IIIFImage
    let on: String

    // optional
    let id: URL?


    init?(_ json: [String: Any]) {

        guard let motivation = json["motivation"] as? String,
            let on = json["on"] as? String,
            let resourceObj = json["resource"] as? [String: Any],
            let resource = IIIFImage(resourceObj) else {
                return nil
        }

        self.motivation = motivation
        self.on = on
        self.resource = resource

        if let value = json["@id"] as? String {
            id = URL(string: value)
        } else {
            id = nil
        }
    }
}
