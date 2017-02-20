//
//  PageThumbnailCell.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 20/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class PageThumbnailCell: UICollectionViewCell {
    
    static let reuseId = "pageThumbnail"
    
    @IBOutlet weak var thumbnail: UIImageView? {
        didSet {
            thumbnail?.backgroundColor = UIColor.lightGray
        }
    }
    
    var viewModel: CanvasViewModel? {
        willSet {
            viewModel?.delegate = nil
        }
        didSet {
            viewModel?.delegate = self
        }
    }
}

extension PageThumbnailCell: CanvasThumbnailDelegate {
    
    func showImage(data: Data?) {
        if data != nil {
            thumbnail?.image = UIImage(data: data!)
        }
    }
}
