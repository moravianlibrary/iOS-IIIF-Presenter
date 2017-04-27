//
//  ManifestController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 19/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class ManifestController: UIViewController {

    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = NSLocalizedString("title", comment: "") + ":"
        }
    }
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    
    var viewModel: ManifestViewModel? {
        willSet {
            viewModel?.delegate = nil
        }
        didSet {
            viewModel?.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.delegate = self
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collection.collectionViewLayout.invalidateLayout()
    }
}

extension ManifestController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.manifest.sequences?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel!.manifest.sequences![section].canvases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageThumbnailCell.reuseId, for: indexPath) as! PageThumbnailCell
        
        let canvas = viewModel!.manifest.sequences![indexPath.section].canvases[indexPath.item]
        cell.viewModel = CanvasViewModel(canvas)
        
        return cell
    }
}

extension ManifestController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension ManifestController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let diff = view.frame.width > view.frame.height ? 1 : 0
        let itemsPerRow = CGFloat((Constants.cardsPerRow + diff) * 3)
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = (availableWidth / itemsPerRow) - 1
        let aspectRatio: CGFloat = 1
        return CGSize(width: widthPerItem, height: widthPerItem * aspectRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension ManifestController: CardDelegate {
    
    func setTitle(title: String) {
        value?.text = title
    }
    
    func loadingDidStart() {}
    func setImage(data: Data?) {}
    func setDate(date: Date?) {}
    func loadingDidFail() {}
    func replaceItem(item: Any) {}
}
