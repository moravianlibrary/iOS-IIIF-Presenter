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
    @IBOutlet weak var rawLabel: UITextView!
    @IBOutlet weak var emptyView: UIView!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    
    var viewModel: ManifestViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dynamic row height
        table.rowHeight = UITableViewAutomaticDimension
        table.estimatedRowHeight = 60
        
        // navigation bar item
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Raw", style: .plain, target: self, action: #selector(showRawJson))
    }
    
    func showRawJson() {
        guard let rawData = viewModel?.manifest.rawJson else {
            return
        }
        
        if rawLabel.isHidden {
            rawLabel.text = String(describing: rawData)
            rawLabel.isHidden = false
        } else {
            rawLabel.isHidden = true
        }
    }
    
    fileprivate func handleItemsCount() {
        let total = (viewModel?.metaInfoCount ?? 0) +
            (viewModel?.manifest.metadata?.items.count ?? 0)
        emptyView.isHidden = (total > 0)
    }
}


extension ManifestController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (viewModel?.manifest.metadata?.items.first != nil ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        handleItemsCount()
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
            value = item.getValue(forLanguage: Constants.lang)
        }
        
        cell.fillIn(title: title, value: value)
        
        return cell
    }
}
