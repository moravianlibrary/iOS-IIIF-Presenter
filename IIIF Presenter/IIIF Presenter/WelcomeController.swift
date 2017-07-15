//
//  WelcomeController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 26/06/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class WelcomeController: UIViewController {

    static let storyboardId = "welcomeController"
    
    @IBOutlet weak var pageIndicator: UIPageControl?
    @IBOutlet weak var collection: UICollectionView?
    
    fileprivate let extensionUrl = URL(string: "https://kramerius.mzk.cz/search/iiif-presentation/uuid:9ebcb206-24b7-4dc7-b367-3d9ad7179c23/manifest")!
    
    fileprivate var texts = [String]()
    fileprivate var images = [UIImage?]()
    fileprivate var buttons = [(action: () -> (), title: String)?]()
    
    fileprivate var collectionItemSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let bExtensionTry = {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(self.extensionUrl)
//            } else {
//                UIApplication.shared.openURL(self.extensionUrl)
//            }
//        }
        let bTutorialEnd = {
            self.endDisplayingController()
        }
        
        let sWelcome = NSLocalizedString("welcome", comment: "")
        let sExtensionTutorial = NSLocalizedString("extension_tutorial", comment: "")
//        let sExtensionTry = NSLocalizedString("extension_try", comment: "")
        let sTutorialBye = NSLocalizedString("tutorial_bye", comment: "")
        let sTutorialEnd = NSLocalizedString("tutorial_end", comment: "")
        
        texts = [sWelcome, sExtensionTutorial, sTutorialBye]
        images = [UIImage(named: "icon_iiif"), UIImage(named: "action_extension"), nil]
        buttons = [nil, nil, (bTutorialEnd, sTutorialEnd)]
        
        pageIndicator?.numberOfPages = texts.count
    }
    
    func didPressButton() {
        guard let index = pageIndicator?.currentPage, let block = buttons[index]?.action else {
            return
        }
        block()
    }
    
    private func endDisplayingController() {
        // TODO: save to UserDefaults not to show this tutorial again
        Constants.appDelegate.showApplicationController()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let offset = collection?.contentOffset
        let index = CGFloat(pageIndicator?.currentPage ?? 0)
        let newOffset = CGPoint(x: index * size.width, y: offset!.y)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.collection?.collectionViewLayout.invalidateLayout()
            self.collection?.setContentOffset(newOffset, animated: false)
            self.pageIndicator?.currentPage = Int(index)
        }, completion: nil)
    }
}

extension WelcomeController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return texts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WelcomeCell.reuseId, for: indexPath) as! WelcomeCell
        
        cell.welcomeController = self
        cell.descriptionLabel?.text = texts[indexPath.item]
        cell.descriptionImage?.image = images[indexPath.item]
        
        cell.button?.isHidden = (buttons[indexPath.item] == nil)
        cell.button?.setTitle(buttons[indexPath.item]?.title, for: .normal)
        
        return cell
    }
}

extension WelcomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionItemSize = collection?.bounds.size ?? .zero
        return collectionItemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension WelcomeController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let itemSize = collectionItemSize.width
        let offsetX = scrollView.contentOffset.x + view.frame.width/2
        let index = Int(offsetX / itemSize)
        pageIndicator?.currentPage = index
    }
}
