//
//  ViewerController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 20/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class ViewerController: UIViewController {

    fileprivate let manifestDetail = "ManifestDetail"
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var pageNumber: UILabel!
    @IBOutlet weak var pageNumberView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var controlSlider: UISlider!
    @IBOutlet weak var controlViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionTopConstraint: NSLayoutConstraint!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
    fileprivate var cellSize: CGSize = .zero
    
    var keepQuality: String? {
        didSet {
            collection.reloadData()
        }
    }
    var keepFormat: String? {
        didSet {
            collection.reloadData()
        }
    }
    var currentQuality: String? {
        didSet {
            guard currentQuality != nil else {
                return
            }
            updateImageSettings()
        }
    }
    var currentFormat: String? {
        didSet {
            guard currentFormat != nil else {
                return
            }
            updateImageSettings()
        }
    }
    
    fileprivate var actionBarItem: UIBarButtonItem!
    fileprivate var currentPage: Int = 0 {
        didSet {
            pageNumber.text = String(currentPage + 1) // human readable
            controlSlider.value = Float(currentPage)
        }
    }
    
    fileprivate var hideStatusBar = false
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    var viewModel: ManifestViewModel? {
        didSet {
            collection?.reloadData()
            title = viewModel?.manifest.title.getSingleValue()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let info = UIButton(type: .infoLight)
        let settingsImage = UIImage(named: "settings")
        info.setImage(settingsImage, for: .normal)
        info.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        actionBarItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareManifest))
        navigationItem.rightBarButtonItems = [actionBarItem,UIBarButtonItem(customView: info)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // needs to be called to unify offset on ios 9 and 10 versions
        collection.layoutIfNeeded()
        
        // just in case any rotation has been done on any other controller
        collection.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let offset = collection?.contentOffset
        let index = CGFloat(currentPage)
        let newOffset = CGPoint(x: index * size.width, y: offset!.y)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.collection?.collectionViewLayout.invalidateLayout()
            self.collection?.setContentOffset(newOffset, animated: false)
            self.currentPage = Int(index)
        }, completion: nil)
    }
    
    @objc func showInfo() {
        performSegue(withIdentifier: manifestDetail, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ManifestController {
            controller.viewModel = viewModel
            controller.viewer = self
            if let currentCell = collection.cellForItem(at: IndexPath(item: currentPage, section: 0)) as? ViewerCell {
                controller.keepChanges = keepQuality != nil || keepFormat != nil
                controller.currentFormat = keepFormat ?? currentCell.viewer?.currentFormat
                controller.currentQuality = keepQuality ?? currentCell.viewer?.currentQuality
                controller.imageFormats = currentCell.viewer?.imageFormats
                controller.imageQualities = currentCell.viewer?.imageQualities
            }
        } else if let controller = segue.destination as? ThumbnailController {
            controller.viewerController = self
            controller.viewModel = viewModel
        }
    }
    
    fileprivate let animationLength: TimeInterval = 0.4
    fileprivate let hideDelay: TimeInterval = 2
    fileprivate func showPageNumber() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        UIView.animate(withDuration: animationLength) {
            self.pageNumberView.alpha = 1.0
        }
        perform(#selector(hidePageNumber), with: nil, afterDelay: hideDelay)
    }
    
    @objc func hidePageNumber() {
        UIView.animate(withDuration: animationLength) {
            self.pageNumberView.alpha = 0.0
        }
    }
    
    fileprivate func handleCanvasesCount(_ count: Int) {
        emptyView.isHidden = (count > 0)
        controlSlider.maximumValue = Float(count - 1)
    }
    
    func shareManifest() {
        ShareUtil.share(viewModel?.manifest, fromController: self, barItem: actionBarItem)
    }
    
    @IBAction func sliderMoved() {
        let pageNum = Int(controlSlider.value)
        let index = IndexPath(item: pageNum, section: 0)
        collection.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
    }
    
    func showItem(at item: Int) {
        let index = IndexPath(item: item, section: 0)
        collection.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
    }
    
    fileprivate func updateImageSettings() {
        if let currentCell = collection.cellForItem(at: IndexPath(item: currentPage, section: 0)) as? ViewerCell {
            currentCell.set(quality: currentQuality, format: currentFormat)
        }
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
        cell.set(quality: keepQuality, format: keepFormat)
        
        return cell
    }
}


extension ViewerController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let itemWidth = cellSize.width
        let offsetX = scrollView.contentOffset.x + scrollView.frame.width/2
        let index = Int(offsetX / itemWidth)
        if currentPage != index {
            currentPage = index
        }
        showPageNumber()
    }
}


extension ViewerController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize = collectionView.bounds.size
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
