//
//  CardDelegate.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/03/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation
import UIKit


protocol CardDelegate: class {
    func loadingDidStart()
    func set(title: String)
    func set(image: UIImage?)
    func set(date: Date?)
    func set(type: String?)
}
