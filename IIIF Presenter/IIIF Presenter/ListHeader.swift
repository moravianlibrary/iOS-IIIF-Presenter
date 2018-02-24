//
//  ListHeader.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 27/04/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit


class ListHeader: UICollectionReusableView {

    static let reuseId = "listHeader"

    fileprivate let titleCellId = "nameCell"
    fileprivate let bulletCellId = "bulletCell"

    @IBOutlet weak var collection: UICollectionView!

    var titles = [String]() {
        didSet {
            collection.reloadData()
        }
    }


    func showCorrectTitle() {
        DispatchQueue.main.async {
            let totalCount = self.collection.numberOfItems(inSection: 0)
            if totalCount > 1 {
                let lastIndex = IndexPath(item: totalCount - 1, section: 0)
                self.collection.scrollToItem(at: lastIndex, at: .left, animated: false)
            }
        }
    }
}


extension ListHeader: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = titles.count * 2 - 1
        return titles.isEmpty ? 0 : count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId = indexPath.item % 2 == 0 ? titleCellId : bulletCellId
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)

        if cellId == titleCellId {
            let label = cell.subviews.first?.subviews.first as? UILabel
            label?.text = titles[indexPath.item / 2]
        }

        return cell
    }
}


extension ListHeader: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isTitle = indexPath.item % 2 == 0

        if isTitle {
            let title = titles[indexPath.item / 2]
            let width = title.width(withFont: UIFont.systemFont(ofSize: 17))
            return CGSize(width: width, height: collectionView.frame.height)
        } else {
            return CGSize(width: 8, height: collectionView.frame.height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}
