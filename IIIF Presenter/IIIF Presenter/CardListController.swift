//
//  CardListController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class CardListController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var messageView: UIView?
    @IBOutlet weak var messageIcon: UIImageView?
    @IBOutlet weak var messageLabel: UILabel?
    
    fileprivate let manifestViewer = "ManifestViewer"
    fileprivate let sectionInsets = UIEdgeInsets(top: 6.0, left: 6.0, bottom: 6.0, right: 6.0)
    
    var showFirstError = false
    var isHistory = false
    var parentName: String?
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
        
        if isHistory {
            spinner.stopAnimating()
        }
        
        collectionView.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // redo all url requests (using cache for already completed ones)
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        
        if !Constants.isIPhone {
            collectionView.collectionViewLayout.invalidateLayout()
            NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // cancel all ongoing url requests
        for cell in collectionView.visibleCells as! [CardCell] {
            cell.viewModel = nil
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ViewerController {
            controller.viewModel = ManifestViewModel(sender as! IIIFManifest)
        } else if let controller = segue.destination as? CardListController {
            let c = sender as! IIIFCollection
            print("Segue to CardListController will never happen.")
            controller.parentName = c.title.getSingleValue()
            controller.viewModel = CollectionViewModel(c)
        }
    }
    
    func orientationDidChange() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if Constants.isIPhone {
            orientationDidChange()
        }
    }
    
    fileprivate func showAlert(_ msg: String?="An error occured") {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func handleSectionNumber(_ number: Int) {
        if let error = viewModel?.loadingError {
            messageView?.isHidden = false
            messageLabel?.text = "\(error.code): \(error.localizedDescription)"
        } else if messageView != nil && !messageView!.isHidden {
            messageView?.isHidden = true
        }
    }
}


extension CardListController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let number = viewModel != nil ? 1 : 0
        handleSectionNumber(number)
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel!.itemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.reuseId, for: indexPath) as! CardCell
        
        let item = viewModel!.getItemAtPosition(indexPath.item)
        cell.collection = self
        cell.viewModel = CardViewModel.getModel(item, delegate: cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ListHeader.reuseId, for: indexPath) as! ListHeader
            
            header.title?.text = parentName
            return header
        } else {
            assert(false, "Unexpected element kind")
        }
    }
}


extension CardListController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CardCell
        if cell.viewModel != nil {
            viewModel?.selectItemAt(indexPath.item)
        }
    }
}


extension CardListController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(Constants.cardsPerRow + (UIDevice.current.orientation.isLandscape ? 1 : 0))
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = (availableWidth / itemsPerRow)
        let aspectRatio: CGFloat = 4/9
//        print("itemsPerRow: \(itemsPerRow), paddingSpace: \(paddingSpace), availableWidth: \(availableWidth), widthPerItem: \(widthPerItem)")
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if parentName != nil, messageLabel != nil {
            let height = 1 + parentName!.heightWithFullWidth(font: messageLabel!.font) + 2*8
            return CGSize(width: collectionView.frame.width, height: height)
        } else {
            return CGSize.zero
        }
    }
}

extension CardListController: CardListDelegate {
    
    func showViewer(manifest: IIIFManifest) {
        performSegue(withIdentifier: manifestViewer, sender: manifest)
    }
    
    func showCollection(collection: IIIFCollection) {
        let controller = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cardListController") as! CardListController
        controller.parentName = collection.title.getSingleValue()
        controller.viewModel = CollectionViewModel(collection)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didStartLoadingData() {
        spinner?.startAnimating()
    }
    
    func didFinishLoadingData(error: NSError?) {
        spinner?.stopAnimating()
        collectionView?.reloadData()
    }
    
    func addDataItem() {
        let index = IndexPath(item: viewModel!.itemsCount - 1, section: 0)
        collectionView.insertItems(at: [index])
    }
}
