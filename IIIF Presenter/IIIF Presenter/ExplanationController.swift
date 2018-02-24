//
//  ExplanationController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 14/07/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit


class ExplanationController: UIViewController {

    @IBOutlet weak var tableView: UITableView?

    // manifest Sachy
    private final let extensionUrl = URL(string: "https://kramerius.mzk.cz/search/iiif-presentation/uuid:9ebcb206-24b7-4dc7-b367-3d9ad7179c23/manifest")!

    fileprivate let cellTry = "cellTry"
    fileprivate var steps: [(text: String, image: UIImage?)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.backgroundColor = .clear
        tableView?.layer.backgroundColor = UIColor.clear.cgColor

        // explanation init
        let images: [UIImage?] = [
            UIImage(named: "action_icon"),
            UIImage(named: NSLocalizedString("step_2_img", comment: "")),
            UIImage(named: NSLocalizedString("step_3_img", comment: "")),
            UIImage(named: NSLocalizedString("step_4_img", comment: "")),
            UIImage(named: NSLocalizedString("step_5_img", comment: ""))
        ]
        let textTop: [String] = [
            NSLocalizedString("step_1", comment: ""),
            NSLocalizedString("step_2", comment: ""),
            NSLocalizedString("step_3", comment: ""),
            NSLocalizedString("step_4", comment: ""),
            NSLocalizedString("step_5", comment: "")
        ]

        for i in 0..<textTop.count {
            steps.append((textTop[i], images[i]))
        }
    }

    @IBAction func tryExtension() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(self.extensionUrl)
        } else {
            UIApplication.shared.openURL(self.extensionUrl)
        }
    }
}


extension ExplanationController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == steps.count {
            // button to try the extension
            let cell = tableView.dequeueReusableCell(withIdentifier: cellTry, for: indexPath)
            cell.subviews.first?.subviews.first?.layer.cornerRadius = 4
            return cell
        }

        // explanation step
        let cell = tableView.dequeueReusableCell(withIdentifier: ExplanationCell.reuseId, for: indexPath) as! ExplanationCell

        let step = steps[indexPath.row]
        cell.number.text = "\(indexPath.row + 1)"
        cell.textTop.text = step.text
        cell.imageHint.image = step.image

        if Constants.isIPad {
            cell.removeConstraint(cell.iPhoneWidthConstraint)
        } else {
            cell.removeConstraint(cell.iPadWidthConstraint)
        }

        return cell
    }
}


extension ExplanationController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == steps.count ? 70 : UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
