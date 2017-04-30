//
//  CardListDelegate.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/03/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

protocol CardListDelegate {
    func didStartLoadingData()
    func showViewer(manifest: IIIFManifest)
    func showCollection(collection: IIIFCollection)
    func didFinishLoadingData(error: NSError?)
    func addDataItem()
}
