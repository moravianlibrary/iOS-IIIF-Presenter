//
//  ThumbnailController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 08/06/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit


class ThumbnailController: UIViewController {

    @IBOutlet weak var collection: UICollectionView!

    fileprivate let sectionInsets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
    fileprivate var thumbnailAspectRatio: CGFloat?

    var viewerController: ViewerController!
    var viewModel: ManifestViewModel? {
        didSet {
            if let c = viewModel?.manifest.sequences?.first?.canvases {
                thumbnailAspectRatio = c.map({ CGFloat($0.height)/CGFloat($0.width) }).max()
            }
            collection?.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // needs to be called to unify offset on ios 9 and 10 versions
        collection.layoutIfNeeded()
    }
}


extension ThumbnailController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel != nil ? 1 : 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.manifest.sequences?.first?.canvases.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageThumbnailCell.reuseId, for: indexPath) as! PageThumbnailCell

        if let canvas = viewModel?.manifest.sequences?.first?.canvases[indexPath.item] {
            cell.viewModel = CanvasViewModel(canvas)
        }

        return cell
    }
}


extension ThumbnailController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewerController.showItem(at: indexPath.item)
        navigationController?.popViewController(animated: true)
    }
}


extension ThumbnailController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemsPerRow = CGFloat(Constants.cardsPerRow * 3 + (UIDevice.current.orientation.isLandscape ? 1 : 0))
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = (availableWidth / itemsPerRow)
        let aspectRatio: CGFloat
        if let ratio = thumbnailAspectRatio {
            aspectRatio = ratio
        } else {
            aspectRatio = collectionView.frame.height/collectionView.frame.width
        }
        return CGSize(width: widthPerItem, height: widthPerItem * aspectRatio)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
