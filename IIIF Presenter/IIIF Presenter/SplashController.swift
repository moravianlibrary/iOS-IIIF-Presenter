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
    
    fileprivate let urlString = "https://drive.google.com/uc?id=0B1TdqMC3wGUJdS1VQ2tlZ0hudXM"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    @IBAction func loadData() {
        errorView.isHidden = true
        spinner.startAnimating()
        
        var c: Collection?
        if let url = URL(string: urlString) {
            let semaphore = DispatchSemaphore(value: 0)
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if data != nil,
                    let serialization = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments),
                    let collection = Collection(serialization as! [String:Any]) {
                    c = collection
                }
                semaphore.signal()
                
            }).resume()
            semaphore.wait()
        }
        
        spinner.stopAnimating()
        
        if c != nil {
            showCollection(c!)
        } else {
            errorView.isHidden = false
        }
    }
    
    func showCollection(_ c: Collection) {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.showCollection(c)
            }
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewModel = CollectionViewModel(c)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        let listController = navigationController.topViewController as! CardListController
        listController.viewModel = viewModel
        
        present(navigationController, animated: false, completion: nil)
    }
}
