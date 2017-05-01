//
//  Constants.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/03/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    static var isIPhone: Bool = true
    
    static var cardsPerRow: Int = 1
    
    static var lang = "en"
    
    static var appDelegate: AppDelegate!
    
    static let dateFormatter = DateFormatter()
    
    static let testUrl = "https://drive.google.com/uc?id=0B1TdqMC3wGUJdS1VQ2tlZ0hudXM"
    
    static let historyUrlKey = "history_urls"
    static let historyTypeKey = "history_types"
    
    static func printDescription() {
        print("model: iP\(isIPhone ? "hone" : "ad").")
        print("cardsPerRow: \(cardsPerRow).")
    }
}

extension String {
    func heightWithFullWidth(font: UIFont) -> CGFloat {
        let margin: CGFloat = 2*8
        let constraintRect = CGSize(width: UIScreen.main.bounds.width - margin, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
