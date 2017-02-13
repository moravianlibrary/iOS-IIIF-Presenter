//
//  CardCell.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

protocol CardDelegate {
    func setTitle(title: String)
    func setImage(data: Data?)
}


class CardCell: UICollectionViewCell {
    
    static let reuseId = "card"
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    var viewModel: ManifestViewModel? {
        willSet {
            viewModel?.delegate = nil
        }
        didSet {
            viewModel?.delegate = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.white
    }
}

extension CardCell: CardDelegate {
    func setTitle(title: String) {
        self.title.text = title
    }
    
    func setImage(data: Data?) {
        if data != nil, let image = UIImage(data: data!) {
            self.image.image = image
        } else {
            self.image.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        }
    }
}
