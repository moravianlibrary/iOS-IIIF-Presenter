//
//  AnalyticsUtil.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 07/06/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Firebase

struct AnalyticsUtil {
    
    static func initAnalytics() {
//        #if !DEBUG
            FirebaseApp.configure()
//        #endif
    }
    
    static func logShare(_ item: Any) {
        guard let data = extract(item) else {
            return
        }
        log(event: AnalyticsEventShare, data: data)
    }
    
    static func logSelect(_ item: Any) {
        guard let data = extract(item) else {
            return
        }
        log(event: AnalyticsEventSelectContent, data: data)
    }
    
    
    fileprivate static func log(event: String, data: (itemId: Any, itemName: Any, itemType: Any)) {
        Analytics.logEvent(event, parameters: [
            AnalyticsParameterItemID: data.itemId,
            AnalyticsParameterItemName: data.itemName,
            AnalyticsParameterContentType: data.itemType])

    }
    
    fileprivate static func extract(_ item: Any) -> (itemId: Any, itemName: Any, itemType: Any)? {
        let id: Any
        let name: Any
        let type: Any
        
        if let m = item as? IIIFManifest {
            id = m.id
            name = m.title.getValueTranslated(lang: "en") ?? m.title.getSingleValue() ?? "unknown"
            type = "manifest"
        } else if let c = item as? IIIFCollection {
            id = c.id
            name = c.title.getValueTranslated(lang: "en") ?? c.title.getSingleValue() ?? "unknown"
            type = "collection"
        } else {
            return nil
        }
        
        return (id, name, type)
    }
}
