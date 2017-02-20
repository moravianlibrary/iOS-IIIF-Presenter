//
//  ManifestController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 19/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class ManifestController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    var viewModel: ManifestViewModel? {
        willSet {
            viewModel?.delegate = nil
        }
        didSet {
            viewModel?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ManifestController: CardDelegate {
    
    func setTitle(title: String) {
        label?.text = title
    }
    
    func setImage(data: Data?) {
    }
}
