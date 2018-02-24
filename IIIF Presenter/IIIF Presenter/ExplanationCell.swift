//
//  ExplanationCell.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 14/07/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit


class ExplanationCell: UITableViewCell {

    static let reuseId = "cellStep"

    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var textTop: UILabel!
    @IBOutlet weak var imageHint: UIImageView!

    @IBOutlet weak var iPhoneWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iPadWidthConstraint: NSLayoutConstraint!
}
