//
//  CardCell.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

protocol CardDelegate {
    func loadingDidStart()
    func setTitle(title: String)
    func setImage(data: Data?)
    func setDate(date: Date?)
    func loadingDidFail()
}


class CardCell: UICollectionViewCell {
    
    static let reuseId = "card"
    
    @IBOutlet weak var image: UIImageView?
    @IBOutlet weak var title: UILabel?
    @IBOutlet weak var date: UILabel?
    @IBOutlet weak var loading: UIVisualEffectView?
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView?
    
    fileprivate let dateFormatter = DateFormatter()
    
    weak var collection: CardListController?
    var viewModel: ManifestViewModel? {
        willSet {
            viewModel?.delegate = nil
        }
        didSet {
            image?.image = nil
            viewModel?.delegate = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dateFormatter.dateFormat = "DD.MM.YYYY hh:mm:ss"
    }
}


extension CardCell: CardDelegate {
    
    func loadingDidStart() {
        // activity indicator stops spinning on reuse, so we need to start it again
        loadingSpinner?.startAnimating()
        loading?.isHidden = false
    }
    
    func setTitle(title: String) {
        self.title?.text = title
        loading?.isHidden = true
    }
    
    func setImage(data: Data?) {
        if data != nil, let image = UIImage(data: data!) {
            self.image?.image = image
        } else {
            self.image?.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        }
    }
    
    func setDate(date: Date?) {
        if date != nil {
            self.date?.text = dateFormatter.string(from: date!)
        } else {
            self.date?.text = nil
        }
    }
    
    func loadingDidFail() {
        collection?.deleteCell(self)
    }
}
