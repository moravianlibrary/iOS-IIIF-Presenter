//
//  SplashController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 19/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class SplashController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var errorView: UIView!
    
    var launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    
    fileprivate let urlString = "https://drive.google.com/uc?id=0B1TdqMC3wGUJdS1VQ2tlZ0hudXM"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    @IBAction func loadData() {
        errorView.isHidden = true
        spinner.startAnimating()
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var c: IIIFCollection?
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if data != nil,
                    let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments),
                    let collection = IIIFCollection(serialization as! [String:Any]) {
                    c = collection
                }
                semaphore.signal()
                
            }).resume()
            semaphore.wait()
        }
        
        var m: IIIFManifest?
        if let text = (launchOptions?[.url] as? URL)?.absoluteString {
            let urlString = String(text.characters.dropFirst(5))
            if let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    if data != nil,
                        let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments),
                        let manifest = IIIFManifest(serialization as! [String:Any]) {
                        m = manifest
                    }
                    semaphore.signal()
                    
                }).resume()
                semaphore.wait()
            }
        }
        
        spinner.stopAnimating()
        
        if c != nil {
            showCollection(m, c!)
        } else {
            errorView.isHidden = false
        }
    }
    
    func showCollection(_ m: IIIFManifest?, _ c: IIIFCollection) {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.showCollection(m, c)
            }
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        let tabController = navigationController.viewControllers.first as! MenuController
        tabController.searchCollection = c
        if m != nil {
            tabController.historyCollection = IIIFCollection.createCollectionWith([m!])
        }
        
        present(navigationController, animated: false, completion: nil)
    }
}
