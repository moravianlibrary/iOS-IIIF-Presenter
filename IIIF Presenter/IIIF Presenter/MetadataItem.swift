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
            self.label = key.trimmed()
        } else if let keys = json["label"] as? [[String:String]] {
            labelTranslations = [:]
            for key in keys {
                guard let lang = key["@language"], let value = key["@value"] else {
                    print("Language or value not present in metadata label item.")
                    continue
                }
                let valueTrimmed = value.trimmed()
                labelTranslations![lang] = valueTrimmed
                if let simpleLang = lang.components(separatedBy: "-").first {
                    labelTranslations![simpleLang] = valueTrimmed
                }
            }
        } else {
            print("Unexpected label format: \(String(describing: json["label"])).")
            return nil
        }
        
        if let value = json["value"] as? String {
            self.value = value.trimmed()
        } else if let values = json["value"] as? [String] {
            valueList = values.map({ $0.trimmed() })
        } else if let values = json["value"] as? [[String:String]] {
            valueTranslations = [:]
            for key in values {
                guard let lang = key["@language"], let value = key["@value"] else {
                    print("Language or value not present in metadata value item.")
                    continue
                }
                let valueTrimmed = value.trimmed()
                valueTranslations![lang] = valueTrimmed
                if let simpleLang = lang.components(separatedBy: "-").first {
                    valueTranslations![simpleLang] = valueTrimmed
                }

            }
        } else {
            print("Unexpected value format: \(String(describing: json["value"])).")
            return nil
        }
    }
    
    func getLabel(forLanguage lang: String) -> String? {
        let search = labelTranslations?[lang] ?? label
        let def = labelTranslations?["en"] ?? labelTranslations?.values.first
        return search ?? def
    }
    
    func getValue(forLanguage lang: String) -> String? {
        let search = valueTranslations?[lang] ?? valueList?.first ?? value
        let def = valueTranslations?["en"] ?? valueTranslations?.values.first
        return search ?? def
    }
}
