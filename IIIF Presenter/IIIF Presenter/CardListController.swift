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
    fileprivate let refreshControl = UIRefreshControl()
    
    fileprivate let manifestViewer = "ManifestViewer"
    fileprivate let sectionInsets = UIEdgeInsets(top: 6.0, left: 6.0, bottom: 6.0, right: 6.0)
    
    var showFirstError = false
    var isHistory = false
    var parentNames: [String]?
    var viewModel: CollectionViewModel? {
        willSet {
            viewModel?.delegate = nil
        }
        didSet {
            viewModel?.delegate = self
            startObserving()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.clear
        
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loadingIndicator?.color = Constants.greenColor
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.addSubview(refreshControl)

        collectionView.reactive.dataSource.forwardTo = self
        startObserving()
    }

    private func startObserving() {
        bag.dispose()
        guard collectionView != nil else { return }

        viewModel?.data.bind(to: collectionView) { (array, index, collectionView) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.reuseId, for: index) as! CardCell

            let item = array.array[index.item]
            cell.collection = self
            cell.viewModel = CardViewModel.getModel(item, delegate: cell)

            return cell
        }.dispose(in: bag)

        viewModel?.data.observeNext { event in
            if event.source.isEmpty, !self.isHistory {
                self.spinner.startAnimating()
            } else {
                self.spinner.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        }.dispose(in: bag)
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
    
    @objc func refreshData() {
        viewModel?.refreshData()
    }
    
    @objc func orientationDidChange() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if Constants.isIPhone {
            orientationDidChange()
        }
    }
    
    fileprivate func handleSectionNumber(_ number: Int) {
        if !isHistory, let error = viewModel?.loadingError, number == 0 {
            messageView?.isHidden = false
            messageLabel?.text = "\(error.code): \(error.localizedDescription)"
            messageButton?.isHidden = false
        } else if messageView != nil && !messageView!.isHidden {
            messageView?.isHidden = true
        }
    }
    
    fileprivate func handleItemsCount(_ count: Int) {
        if count == 0 {
            messageView?.isHidden = false
            messageLabel?.text = NSLocalizedString("empty_collection", comment: "")
            messageButton?.isHidden = true
        } else {
            messageView?.isHidden = true
        }
    }
    
    @objc func reloadData() {
        if let url = viewModel?.collection.id {
            URLCache.shared.removeCachedResponse(for: URLRequest(url: url))
        }
        messageView?.isHidden = true
        viewModel?.beginLoading()
    }
    
    @objc func shareCollection() {
        ShareUtil.share(viewModel?.collection, fromController: self, barItem: actionBarItem)
    }
}


extension CardListController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        fatalError("This method should never get called as the Bond framework handles this.")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("This method should never get called as the Bond framework handles this.")
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("This method should never get called as the Bond framework handles this.")
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
        loadingIndicator?.startAnimating()
    }
    
    func didFinishLoadingData(error: NSError?) {
        spinner?.stopAnimating()
        loadingIndicator?.stopAnimating()
        handleItemsCount(viewModel?.data.count ?? 0)
    }
}
