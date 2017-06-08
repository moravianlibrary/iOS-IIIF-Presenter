//
//  CardListController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class CardListController: UIViewController {
    
    static let id = "cardListController"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var messageView: UIView?
    @IBOutlet weak var messageIcon: UIImageView?
    @IBOutlet weak var messageLabel: UILabel?
    @IBOutlet weak var messageButton: UIButton?
    
    fileprivate var loadingIndicator: UIActivityIndicatorView?
    fileprivate var actionBarItem: UIBarButtonItem?
    
    fileprivate let manifestViewer = "ManifestViewer"
    fileprivate let sectionInsets = UIEdgeInsets(top: 6.0, left: 6.0, bottom: 6.0, right: 6.0)
    fileprivate var knownCount = 0
    
    var showFirstError = false
    var isHistory = false
    var parentNames: [String]?
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
        
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loadingIndicator?.color = Constants.greenColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set proper navigation items
        if let menu = parent as? MenuController {
            menu.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingIndicator!)
        } else if navigationItem.rightBarButtonItems == nil {
            actionBarItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareCollection))
            navigationItem.rightBarButtonItems = [actionBarItem!, UIBarButtonItem(customView: loadingIndicator!)]
        }
        
        // needs to be called to unify offset on ios 9 and 10 versions
        collectionView.layoutIfNeeded()
        
        // redo all url requests (using cache for already completed ones)
        viewModel?.beginLoading()
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        
        if Constants.isIPad {
            collectionView.collectionViewLayout.invalidateLayout()
            NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // cancel all ongoing url requests
        viewModel?.stopLoading()
        for cell in collectionView.visibleCells as! [CardCell] {
            cell.viewModel = nil
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ViewerController {
            controller.viewModel = ManifestViewModel(sender as! IIIFManifest)
        } else {
            log("Segue to other controller will never happen.", level: .Warn)
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
    
    fileprivate func handleSectionNumber(_ number: Int) {
        if !isHistory, let error = viewModel?.loadingError, number == 0 || knownCount == 0 {
            messageView?.isHidden = false
            messageLabel?.text = "\(error.code): \(error.localizedDescription)"
            messageButton?.isHidden = false
        } else if messageView != nil && !messageView!.isHidden {
            messageView?.isHidden = true
        }
    }
    
    fileprivate func handleItemsCount() {
        if !(viewModel?.isLoading ?? true), knownCount == 0 {
            messageView?.isHidden = false
            messageLabel?.text = NSLocalizedString("empty_collection", comment: "")
            messageButton?.isHidden = true
        } else {
            messageView?.isHidden = true
        }
    }
    
    @IBAction func reloadData() {
        if let url = viewModel?.collection.id {
            URLCache.shared.removeCachedResponse(for: URLRequest(url: url))
        }
        messageView?.isHidden = true
        viewModel?.beginLoading()
    }
    
    func shareCollection() {
        ShareUtil.share(viewModel?.collection, fromController: self, barItem: actionBarItem)
    }
}


extension CardListController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let number = viewModel != nil ? 1 : 0
        handleSectionNumber(number)
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        knownCount = viewModel!.itemsCount
        handleItemsCount()
        return knownCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.reuseId, for: indexPath) as! CardCell
        
        if let item = viewModel!.getItemAtPosition(indexPath.item) {
            cell.collection = self
            cell.viewModel = CardViewModel.getModel(item, delegate: cell)
        } else {
            cell.collection = nil
            cell.viewModel = nil
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ListHeader.reuseId, for: indexPath) as! ListHeader
            
            header.titles = parentNames ?? []
            return header
        }
        
        assertionFailure("Unexpected element kind")
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionHeader, let header = view as? ListHeader {
            header.showCorrectTitle()
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
//        log("itemsPerRow: \(itemsPerRow), paddingSpace: \(paddingSpace), availableWidth: \(availableWidth), widthPerItem: \(widthPerItem)")
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
        if parentNames != nil, messageLabel != nil {
            let height: CGFloat = 40
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
        var currentTitles = parentNames ?? []
        if let title = collection.title.getSingleValue() {
            currentTitles.append(title)
        }
        controller.parentNames = currentTitles
        controller.viewModel = CollectionViewModel(collection)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didStartLoadingData() {
        if knownCount == 0 {
            spinner?.startAnimating()
        }
        loadingIndicator?.startAnimating()
    }
    
    func didFinishLoadingData(error: NSError?) {
        spinner?.stopAnimating()
        loadingIndicator?.stopAnimating()
        collectionView?.reloadData()
    }
    
    func addDataItem() {
        guard isViewLoaded, let count = viewModel?.itemsCount, count != knownCount else {
            return
        }
        
        let index = IndexPath(item: count - 1, section: 0)
        collectionView.insertItems(at: [index])
        spinner?.stopAnimating()
    }
}
