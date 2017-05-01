//
//  ManifestController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 19/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class ManifestController: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var collection: UICollectionView!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    
    var viewModel: ManifestViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dynamic row height
        table.rowHeight = UITableViewAutomaticDimension
        table.estimatedRowHeight = 60
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        collection.collectionViewLayout.invalidateLayout()
//    }
}

//extension ManifestController: UICollectionViewDataSource {
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return viewModel?.manifest.sequences?.count ?? 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return viewModel!.manifest.sequences![section].canvases.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageThumbnailCell.reuseId, for: indexPath) as! PageThumbnailCell
//        
//        let canvas = viewModel!.manifest.sequences![indexPath.section].canvases[indexPath.item]
//        cell.viewModel = CanvasViewModel(canvas)
//        
//        return cell
//    }
//}
//
//extension ManifestController: UICollectionViewDelegate {
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    }
//}
//
//extension ManifestController: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let diff = view.frame.width > view.frame.height ? 1 : 0
//        let itemsPerRow = CGFloat((Constants.cardsPerRow + diff) * 3)
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let availableWidth = view.frame.width - paddingSpace
//        let widthPerItem = (availableWidth / itemsPerRow) - 1
//        let aspectRatio: CGFloat = 1
//        return CGSize(width: widthPerItem, height: widthPerItem * aspectRatio)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.left
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.left
//    }
//}

extension ManifestController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (viewModel?.manifest.metadata?.items.first != nil ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel?.metaInfoCount ?? 0
        case 1:
            return viewModel?.manifest.metadata?.items.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "metadataCell", for: indexPath) as! MetadataCell
        
        var title: String?
        var value: String?
        
        if indexPath.section == 0 {
            title = viewModel?.getMetaInfoKey(at: indexPath.row)
            value = viewModel?.getMetaInfo(at: indexPath.row, forLanguage: Constants.lang)
        } else {
            let item = viewModel!.manifest.metadata!.items[indexPath.row]
            title = item.getLabel(forLanguage: Constants.lang)
            if let val = item.getValue(forLanguage: Constants.lang) {
                if val.contains("<"), let attributedText = try? NSMutableAttributedString(data: val.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
                
                    value = attributedText.string
                } else {
                    value = val
                }
            }
        }
        
        cell.fillIn(title: title, value: value)
        
        return cell
    }
}
