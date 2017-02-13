//
//  MultiProperty.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

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
            singleValue = value
        } else if let array = json as? [String] {
            // simple array containing only Element
            arrayValue.append(contentsOf: array)
        } else if let array = json as? [Any] {
            // mixed array
            for item in array {
                if let value = item as? String {
                    arrayValue.append(value)
                } else if let dict = item as? [String:Any] {
                    if let key = dict["@language"] as? String {
                        let value = dict["@value"]
                        dictValue[key] = value
                    } else if let key = dict["label"] as? String {
                        let value = dict["value"]
                        dictValue[key] = value
                    }
                }
            }
        }
    }
    
    func getValueList() -> [String]? {
        var array = [String](arrayValue)
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
