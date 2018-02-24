//
//  WelcomeCell.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 28/06/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit


class WelcomeCell: UICollectionViewCell {

    static let reuseId = "welcomeCell"

    @IBOutlet weak var descriptionLabel: UILabel? {
        didSet {
            if Constants.isIPad {
                descriptionLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 10)
            }
        }
    }
    @IBOutlet weak var descriptionImage: UIImageView?
    @IBOutlet weak var button: UIButton? {
        didSet {
            button?.layer.cornerRadius = 4
        }
    }

    var welcomeController: WelcomeController?


    @IBAction func buttonPressed() {
        welcomeController?.didPressButton()
    }
}
