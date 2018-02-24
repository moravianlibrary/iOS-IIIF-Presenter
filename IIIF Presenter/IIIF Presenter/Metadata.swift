//
//  Metadata.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 03/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation


struct Metadata {

    let items: [MetadataItem]

    init?(_ json: Any?) {
        guard json != nil else {
            return nil
        }

        var items = [MetadataItem]()
        if let array = json as? [[String: Any]] {
            for item in array {
                if let metaItem = MetadataItem(json: item) {
                    items.append(metaItem)
                }
            }
        } else if let obj = json as? [String: Any], let metaItem = MetadataItem(json: obj) {
            items.append(metaItem)
        } else {
            log("Unsupported metadata structure: \(String(describing: json)).", level: .Error)
            return nil
        }

        self.items = items
    }
}
