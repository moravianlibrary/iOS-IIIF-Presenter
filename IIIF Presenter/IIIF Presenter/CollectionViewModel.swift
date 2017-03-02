//
//  CollectionViewModel.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

class CollectionViewModel {
    
    fileprivate let testUrl = "https://drive.google.com/uc?id=0B1TdqMC3wGUJdS1VQ2tlZ0hudXM"
    
    var collection: IIIFCollection
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
    
    func deleteManifestAt(_ index: Int) {
        collection.manifests.remove(at: index)
    }
}
