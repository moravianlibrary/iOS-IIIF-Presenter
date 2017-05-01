//
//  CardCell.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    static let reuseId = "card"
    
    @IBOutlet weak var image: UIImageView?
    @IBOutlet weak var title: UILabel?
    @IBOutlet weak var date: UILabel?
    @IBOutlet weak var type: UILabel?
    @IBOutlet weak var grayline: UIView?
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView?
    
    weak var collection: CardListController?
    var viewModel: CardViewModel? {
        willSet {
            viewModel?.delegate = nil
        }
        didSet {
            image?.image = nil
            viewModel?.delegate = self
        }
    }
}


extension CardCell: CardDelegate {
    
    func loadingDidStart() {
        // activity indicator stops spinning on reuse, so we need to start it again
        image?.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        loadingSpinner?.startAnimating()
    }
    
    func setTitle(title: String) {
        self.title?.text = title
    }
    
    func setImage(data: Data?) {
        if data != nil, let image = UIImage(data: data!) {
            self.image?.image = image
            self.image?.backgroundColor = UIColor.clear
        }
        loadingSpinner?.stopAnimating()
    }
    
    func setDate(date: Date?) {
        if date != nil {
            self.date?.text = Constants.dateFormatter.string(from: date!)
        } else {
            self.date?.text = nil
        }
    }
    
    func setType(type: String?) {
        if type != nil {
            self.type?.text = type
        } else {
            self.type?.isHidden = true
            self.grayline?.isHidden = true
        }
    }
}
