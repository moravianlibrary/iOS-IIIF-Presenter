//
//  CardDelegate.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/03/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

protocol CardDelegate {
    func loadingDidStart()
    func setTitle(title: String)
    func setImage(data: Data?)
    func setDate(date: Date?)
    func loadingDidFail()
    func replaceItem(item: Any)
}
