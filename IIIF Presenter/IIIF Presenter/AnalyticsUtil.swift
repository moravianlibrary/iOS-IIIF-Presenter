//
//  AnalyticsUtil.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 07/06/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Firebase


struct AnalyticsUtil {

    struct LogData {
        let id: Any
        let name: Any
        let type: Any
    }

    static func initAnalytics() {
        #if !DEBUG
            FirebaseApp.configure()
        #endif
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


    fileprivate static func log(event: String, data: LogData) {
        Analytics.logEvent(event, parameters: [
            AnalyticsParameterItemID: data.id,
            AnalyticsParameterItemName: data.name,
            AnalyticsParameterContentType: data.type])

    }

    fileprivate static func extract(_ item: Any) -> LogData? {
        if let m = item as? IIIFManifest {
            return LogData(id: m.id.absoluteString,
                           name: m.title.getValueTranslated(lang: "en") ?? m.title.getSingleValue() ?? "unknown",
                           type: "manifest")
        } else if let c = item as? IIIFCollection {
            return LogData(id: c.id.absoluteString,
                           name: c.title.getValueTranslated(lang: "en") ?? c.title.getSingleValue() ?? "unknown",
                           type: "collection")
        }
        return nil
    }
}
