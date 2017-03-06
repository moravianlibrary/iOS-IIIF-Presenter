//
//  CardListController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

protocol CardListDelegate {
    func showViewer(manifest: IIIFManifest)
    func didStartLoadingData()
    func didFinishLoadingData()
}

class CardListController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    fileprivate let manifestViewer = "ManifestViewer"
    fileprivate let sectionInsets = UIEdgeInsets(top: 6.0, left: 6.0, bottom: 6.0, right: 6.0)
    fileprivate var isLoading: Bool = false
    
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
        
        if isLoading {
            spinner?.startAnimating()
        }
        collectionView.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // redo all url requests (using cache for already completed ones)
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // cancel all ongoing url requests
        for cell in collectionView.visibleCells as! [CardCell] {
            cell.viewModel = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ViewerController {
            controller.viewModel = ManifestViewModel(sender as! IIIFManifest)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func deleteCell(_ cell: UICollectionViewCell) {
        if let index = collectionView.indexPath(for: cell) {
            viewModel?.deleteManifestAt(index.item)
            collectionView.deleteItems(at: [index])
//            collectionView.reloadData()
        }
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
        let manifestViewModel = ManifestViewModel(manifest, delegate: cell)
        cell.collection = self
        cell.viewModel = manifestViewModel
        
        return cell
    }
}


extension CardListController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CardCell
        if !cell.viewModel!.isLoadingData {
            viewModel?.selectManifestAt(indexPath.item)
        }
    }
}


extension CardListController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(Constants.cardsPerRow + (view.frame.width > view.frame.height ? 1 : 0))
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = (availableWidth / itemsPerRow) - 1
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
    
    func showViewer(manifest: IIIFManifest) {
        performSegue(withIdentifier: manifestViewer, sender: manifest)
    }
    
    func didStartLoadingData() {
        isLoading = true
        spinner?.startAnimating()
    }
    
    func didFinishLoadingData() {
        isLoading = false
        spinner?.stopAnimating()
        collectionView.reloadData()
    }
}
