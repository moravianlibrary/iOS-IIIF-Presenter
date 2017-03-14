//
//  ViewerCell.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 26/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit
import iOSTiledViewer

class ViewerCell: UICollectionViewCell {
    
    static let reuseId = "viewer"
    
    @IBOutlet weak var spinner: UIActivityIndicatorView?
    @IBOutlet weak var viewer: ITVScrollView? {
        didSet {
            viewer?.itvDelegate = self
        }
    }
    
    var viewModel: CanvasViewModel? {
        didSet {
            loadImage()
        }
    }
    
    fileprivate func loadImage() {
        if let url = viewModel?.canvas.images?.first?.resource.service?.id {
            spinner?.startAnimating()
            viewer?.loadImage(url, api: .IIIF)
        }
    }
}

extension ViewerCell: ITVScrollViewDelegate {
    
    func didFinishLoading(error: NSError?) {
        spinner?.stopAnimating()
    }
    
    func errorDidOccur(error: NSError) {
        spinner?.stopAnimating()
        print("error: \(error)")
    }
}
