//
//  MetadataItem.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 30/04/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct MetadataItem {
    
    fileprivate var label: String?
    fileprivate var value: String?
    fileprivate var valueList: [String]?
    fileprivate var labelTranslations: [String:String]?
    fileprivate var valueTranslations: [String:String]?
    
    init?(json: [String:Any]) {
        if let key = json["label"] as? String {
            self.label = key
        } else if let keys = json["label"] as? [[String:String]] {
            labelTranslations = [:]
            for key in keys {
                guard let lang = key["@language"], let value = key["@value"] else {
                    print("Language or value not present in metadata label item.")
                    continue
                }
                labelTranslations![lang] = value
                if let simpleLang = lang.components(separatedBy: "-").first {
                    labelTranslations![simpleLang] = value
                }
            }
        } else {
            print("Unexpected label format: \(String(describing: json["label"])).")
            return nil
        }
        
        if let value = json["value"] as? String {
            self.value = value
        } else if let values = json["value"] as? [String] {
            valueList = values
        } else if let values = json["value"] as? [[String:String]] {
            valueTranslations = [:]
            for key in values {
                guard let lang = key["@language"], let value = key["@value"] else {
                    print("Language or value not present in metadata value item.")
                    continue
                }
                valueTranslations![lang] = value
                if let simpleLang = lang.components(separatedBy: "-").first {
                    valueTranslations![simpleLang] = value
                }

            }
        } else {
            print("Unexpected value format: \(String(describing: json["value"])).")
            return nil
        }
    }
    
    func getLabel(forLanguage lang: String) -> String? {
        return labelTranslations?[lang] ?? labelTranslations?["en"] ?? label
    }
    
    func getValue(forLanguage lang: String) -> String? {
        return valueTranslations?[lang] ?? valueList?.first ?? valueTranslations?["en"] ?? value
    }
}
