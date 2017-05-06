//
//  AboutController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 05/05/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class AboutController: UIViewController {

    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var aboutText: UILabel!
    
    static let id = "aboutController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        version.text! += " " + Constants.version
    }
    
    @IBAction func showIiif() {
        let urlString = "http://iiif.io"
        if let url = URL(string: urlString) {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func showMzk() {
        let urlString = "http://www.mzk.cz"
        if let url = URL(string: urlString) {
            UIApplication.shared.openURL(url)
        }
    }
}
