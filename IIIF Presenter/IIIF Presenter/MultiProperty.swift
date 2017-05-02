//
//  MultiProperty.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//
import UIKit

struct MultiProperty {

    fileprivate var singleValue: String?
    fileprivate var arrayValue = [String]()
    fileprivate var dictValue = [String:Any]()
    
    init?(_ json: Any?) {
        
        guard let json = json else {
            return nil
        }
        
        if let value = json as? String {
            // single value
            singleValue = value.trimmed()
        } else if let array = json as? [String] {
            // simple array containing only Element
            arrayValue.append(contentsOf: array.map({ $0.trimmed() }))
        } else if let dict = json as? [String:Any] {
            parse(dictionary: dict)
        } else if let array = json as? [Any] {
            // mixed array
            for item in array {
                if let value = item as? String {
                    arrayValue.append(value.trimmed())
                } else if let dict = item as? [String:Any] {
                    parse(dictionary: dict)
                } else {
                    print("Nonsupported object: \(String(describing: item)).")
                }
            }
        } else {
            print("Nonsupported object: \(String(describing: json)).")
            return nil
        }
    }
    
    fileprivate mutating func parse(dictionary dict: [String:Any]) {
        if let lang = dict["@language"] as? String, let value = dict["@value"] as? String {
            dictValue[lang] = value.trimmed()
        }
        for (key, val) in dict where key != "@language" && key != "@value"{
            dictValue[key] = val is String ? (val as! String).trimmed() : val
        }
    }
    
    func getSingleValue() -> String? {
        if let val = getValueList()?.first {
            return val
        }
        return nil
    }
    
    func getValueList() -> [String]? {
        var array = arrayValue
        if singleValue != nil {
            array.append(singleValue!)
        }
        for (key,value) in dictValue {
            if let val = value as? String {
                array.append(val)
            } else if let val = value as? [String] {
                array.append(contentsOf: val)
            } else {
                print("\(key):\(value)")
            }
        }
        return array.isEmpty ? nil : array
    }
    
    func getValueTranslated(lang: String) -> String? {
        return dictValue[lang] as? String
    }
}
