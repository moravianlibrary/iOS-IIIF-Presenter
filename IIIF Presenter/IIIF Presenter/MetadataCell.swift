//
//  MetadataCell.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 01/05/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class MetadataCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var value: UILabel!

    func fillIn(title: String?, value: String?) {
        self.title.text = title
        self.value.text = value
    }
}
