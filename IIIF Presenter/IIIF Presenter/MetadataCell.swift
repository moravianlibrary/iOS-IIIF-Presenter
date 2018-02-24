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
    @IBOutlet weak var value: UITextView! {
        didSet {
            // turn off textView implicit padding
            value?.textContainerInset = .zero
            value?.contentInset = .zero
            value?.textContainer.lineFragmentPadding = 0
        }
    }

    func fillIn(title: String?, value: String?) {
        self.title.text = title
        self.value.text = value
    }
}
