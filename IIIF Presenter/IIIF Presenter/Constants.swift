//
//  Constants.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/03/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct Constants {
    
    static var isIPhone: Bool = true
    
    static var cardsPerRow: Int = 1
    
    static var lang = "en"
    
    static let testUrl = "https://drive.google.com/uc?id=0B1TdqMC3wGUJdS1VQ2tlZ0hudXM"
    
    static let historyKey = "history_array"
    
    static func printDescription() {
        print("model: iP\(isIPhone ? "hone" : "ad").")
        print("cardsPerRow: \(cardsPerRow).")
    }
}
