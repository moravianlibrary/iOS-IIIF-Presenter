//
//  CollectionViewModel.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

struct CollectionViewModel {
    
    let collection: IIIFCollection
    var delegate: CardListDelegate?
    
    var manifestCount: Int {
        return collection.manifests.count
    }
    
    init(_ collection: IIIFCollection) {
        self.collection = collection
    }
    
    func getManifestAtPosition(_ i: Int) -> IIIFManifest {
        return collection.manifests[i]
    }
    
    func selectManifestAt(_ index: Int) {
        let manifest = getManifestAtPosition(index)
        delegate?.showViewer(manifest: manifest)
    }
}
