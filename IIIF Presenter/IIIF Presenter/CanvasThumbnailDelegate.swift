//
//  CanvasThumbnailDelegate.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/03/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

protocol CanvasThumbnailDelegate {
    func showImage(data: Data?)
    func showTitle(_ title: String?)
}
