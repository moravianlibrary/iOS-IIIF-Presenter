//
//  ShareUtil.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 07/06/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit


struct ShareUtil {

    static func share(_ item: Any?, fromController controller: UIViewController, barItem: UIBarButtonItem?) {
        guard item != nil, !Constants.isIPad || barItem != nil else {
            return
        }

        let itemUrl: URL!
        let title: String?
        var isCollection = false
        if let manifest = item as? IIIFManifest {
            itemUrl = manifest.id
            title = manifest.title.getValueTranslated(lang: Constants.lang, defaultLanguage: "en") ?? manifest.title.getSingleValue()
        } else if let collection = item as? IIIFCollection {
            isCollection = true
            if let members = collection.members, members.isEmpty {
                return
            }
            itemUrl = collection.id
            title = collection.title.getValueTranslated(lang: Constants.lang, defaultLanguage: "en") ?? collection.title.getSingleValue()
        } else {
            return
        }

        AnalyticsUtil.logShare(item!)

        let start = NSLocalizedString("share_msg_start", comment: "")
        let collection = NSLocalizedString("share_msg_collection", comment: "")
        let manifest = NSLocalizedString("share_msg_manifest", comment: "")
        let name = NSLocalizedString("share_msg_name", comment: "")
        let link = NSLocalizedString("share_msg_link", comment: "")
        let unknown = NSLocalizedString("share_msg_unknown", comment: "")
        let message = "\(start) \(isCollection ? collection : manifest)! \(name) '\(title ?? unknown)' \(link):\n"

        let activityController = UIActivityViewController(activityItems: [message, itemUrl], applicationActivities: nil)
        activityController.excludedActivityTypes = [.assignToContact, .print, .saveToCameraRoll]

        if Constants.isIPad {
            activityController.modalPresentationStyle = .popover
            activityController.popoverPresentationController?.barButtonItem = barItem
        }
        controller.present(activityController, animated: true, completion: nil)
    }
}
