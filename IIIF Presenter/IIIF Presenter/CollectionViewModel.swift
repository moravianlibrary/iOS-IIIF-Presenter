//
//  CollectionViewModel.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 13/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import Foundation

class CollectionViewModel {
    
    var collection: IIIFCollection
    var delegate: CardListDelegate?
    var loadingError: NSError?
    
    var itemsCount: Int {
        return collection.members != nil ? collection.members!.count : 0
    }
    
    
    static func createWithUrl(_ url: String, delegate: CardListDelegate?, items: [Any]=[]) -> CollectionViewModel {
        return CollectionViewModel(url, delegate, items)
    }
    
    
    init(_ collection: IIIFCollection) {
        self.collection = collection
        if collection.members == nil {
            downloadData(collection.id)
        }
    }
    
    fileprivate init(_ urlString: String, _ delegate: CardListDelegate?, _ items: [Any]) {
        collection = IIIFCollection.createCollectionWith(items)
        self.delegate = delegate
        if let url = URL(string: urlString) {
            delegate?.didStartLoadingData()
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                var err: NSError? = nil
                if data != nil,
                    let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                    if let c = IIIFCollection(serialization as! [String:Any]) {
                        self.collection = c
                    } else if let m = IIIFManifest(serialization as! [String:Any]) {
                        self.collection.members!.insert(m, at: 0)
                    } else {
                        err = NSError(domain: "cz.mzk", code: 102, userInfo: [NSLocalizedDescriptionKey: ["en":"Parsing error", "cz":"Chyba parsovani"]])
                        print("Unknown IIIF structure at \(urlString).")
                    }
                } else if error != nil {
                    err = error as? NSError
                    print("Request error from \(urlString).")
                } else {
                    err = NSError(domain: "cz.mzk", code: 101, userInfo: [NSLocalizedDescriptionKey: ["en":"Parsing error", "cz":"Chyba parsovani"]])
                    print("Parsing error from \(urlString).")
                }
                
                self.loadingError = err
                DispatchQueue.main.async {
                    self.delegate?.didFinishLoadingData(error: err)
                }
            }).resume()
        } else {
            print("Is not valid url: \(urlString).")
        }
    }
    
    
    fileprivate func downloadData(_ url: URL) {
        delegate?.didStartLoadingData()
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            var err: NSError? = nil
            if data != nil,
                let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                if let c = IIIFCollection(serialization as! [String:Any]) {
                    self.collection = c
                } else if let m = IIIFManifest(serialization as! [String:Any]) {
                    self.collection.members!.insert(m, at: 0)
                } else {
                    err = NSError(domain: "cz.mzk", code: 102, userInfo: [NSLocalizedDescriptionKey: ["en":"Parsing error", "cz":"Chyba parsovani"]])
                    print("Unknown IIIF structure at \(url.absoluteString).")
                }
            } else if error != nil {
                err = error as? NSError
                print("Request error from \(url.absoluteString).")
            } else {
                err = NSError(domain: "cz.mzk", code: 101, userInfo: [NSLocalizedDescriptionKey: ["en":"Parsing error", "cz":"Chyba parsovani"]])
                print("Parsing error from \(url.absoluteString).")
            }
            
            self.loadingError = err
            DispatchQueue.main.async {
                self.delegate?.didFinishLoadingData(error: err)
            }
        }).resume()
    }
    
    func getItemAtPosition(_ i: Int) -> Any {
        return collection.members![i]
    }
    
    func selectItemAt(_ index: Int) {
        let item = getItemAtPosition(index)
        if let m = item as? IIIFManifest {
            delegate?.showViewer(manifest: m)
        } else if let c = item as? IIIFCollection {
            delegate?.showCollection(collection: c)
        }
    }
    
    func deleteItemAt(_ index: Int) {
        let item = collection.members![index]
        let id = item is String ? item as! String : (item is IIIFManifest ? (item as! IIIFManifest).id.absoluteString : (item as! IIIFCollection).id.absoluteString)
        collection.members!.remove(at: index)
        Constants.appDelegate.deleteUserDefaults(id)
    }
    
    func replaceItem(_ item: Any, at index: Int) {
        let element = collection.members![index]
        collection.members![index] = item
        if element is String {
            Constants.appDelegate.updateUserDefaults(item)
        }
    }
}
