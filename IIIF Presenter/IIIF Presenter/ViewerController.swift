//
//  ViewerController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 20/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit
import iOSTiledViewer

class ViewerController: UIViewController {

    @IBOutlet weak var viewer: ITVScrollView? {
        didSet {
            viewer?.itvDelegate = self
        }
    }
    
    var viewModel: ManifestViewModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let url = viewModel?.manifest.sequences?.first?.canvases.first?.images?.first?.resource.service?.id {
            viewer?.loadImage(url, api: .IIIF)
        }
    }
}

extension ViewerController: ITVScrollViewDelegate {
    
    func didFinishLoading(error: NSError?) {
    }
    
    func errorDidOccur(error: NSError) {
    }
}
