//
//  ViewerController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 20/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit
import iOSTiledViewer

class ViewerController: UIViewController {

    fileprivate let manifestDetail = "ManifestDetail"
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var pageNumber: UILabel!
    @IBOutlet weak var pageNumberView: UIView!
    @IBOutlet weak var emptyView: UIView!
    
    fileprivate var actionBarItem: UIBarButtonItem!
    
    var viewModel: ManifestViewModel? {
        didSet {
            collection?.reloadData()
            title = viewModel?.manifest.title.getSingleValue()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let info = UIButton(type: .infoLight)
        info.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        actionBarItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareManifest))
        navigationItem.rightBarButtonItems = [actionBarItem,UIBarButtonItem(customView: info)]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collection.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func showInfo() {
        performSegue(withIdentifier: manifestDetail, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ManifestController {
            controller.viewModel = viewModel
        }
    }
    
    fileprivate let animationLength: TimeInterval = 0.4
    fileprivate let hideDelay: TimeInterval = 2
    fileprivate func showPageNumber(_ num: Int) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        pageNumber.text = String(num)
        UIView.animate(withDuration: animationLength) {
            self.pageNumberView.alpha = 1.0
        }
        perform(#selector(hidePageNumber), with: nil, afterDelay: hideDelay)
    }
    
    func hidePageNumber() {
        UIView.animate(withDuration: animationLength) {
            self.pageNumberView.alpha = 0.0
        }
    }
    
    fileprivate func handleCanvasesCount(_ count: Int) {
        emptyView.isHidden = (count > 0)
    }
    
    func shareManifest() {
        ShareUtil.share(viewModel?.manifest, fromController: self, barItem: actionBarItem)
    }
}


extension ViewerController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let number = viewModel?.manifest.sequences?.count
        return number ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let num = viewModel!.manifest.sequences![section].canvases.count
        handleCanvasesCount(num)
        return num
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewerCell.reuseId, for: indexPath) as! ViewerCell
        
        let canvas = viewModel!.manifest.sequences![indexPath.section].canvases[indexPath.item]
        cell.viewModel = CanvasViewModel(canvas)
        
        return cell
    }
}

extension ViewerController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        showPageNumber(indexPath.item + 1) // human readable
    }
}


extension ViewerController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
