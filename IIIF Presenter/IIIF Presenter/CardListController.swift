//
//  CardListController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

protocol CardListDelegate {
    func showDetail(manifest: Manifest)
}

class CardListController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate let manifestDetail = "showDetail"
    fileprivate let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    fileprivate let itemsPerRow: CGFloat = 1
    
    var viewModel: CollectionViewModel? {
        willSet {
            viewModel?.delegate = nil
        }
        didSet {
            viewModel?.delegate = self
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.lightGray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! ManifestController
        controller.viewModel = ManifestViewModel(sender as! Manifest)
    }
}


extension CardListController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel != nil ? viewModel!.manifestCount : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.reuseId, for: indexPath) as! CardCell
        
        let manifest = viewModel!.getManifestAtPosition(indexPath.item)
        let manifestViewModel = ManifestViewModel(manifest)
        cell.viewModel = manifestViewModel
        
        return cell
    }
}


extension CardListController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.selectManifestAt(indexPath.item)
    }
}


extension CardListController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let aspectRatio: CGFloat = 5/8
        return CGSize(width: widthPerItem, height: widthPerItem * aspectRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension CardListController: CardListDelegate {
    
    func showDetail(manifest: Manifest) {
        performSegue(withIdentifier: manifestDetail, sender: manifest)
    }
}
