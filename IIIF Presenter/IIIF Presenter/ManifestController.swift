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
    @IBOutlet weak var rawLabel: UITextView!

    var viewModel: ManifestViewModel?
    var viewer: ViewerController?

    // settings stuff
    var currentFormat: String?
    var currentQuality: String?
    var imageFormats: [String]?
    var imageQualities: [String]?
    var keepChanges: Bool = false
    fileprivate var numberOfLines = 3
    fileprivate var pickerIndex: IndexPath?
    fileprivate var pickerType: String?
    fileprivate let titles = [NSLocalizedString("img_quality", comment: ""), NSLocalizedString("img_format", comment: "")]
    fileprivate let none = NSLocalizedString("img_none", comment: "")


    override func viewDidLoad() {
        super.viewDidLoad()

        // dynamic row height
        table.rowHeight = UITableViewAutomaticDimension
        table.estimatedRowHeight = 60

        // navigation bar item
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Raw", style: .plain, target: self, action: #selector(showRawJson))
    }

    @objc
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

    @IBAction func keepChangesValueChanged() {
        keepChanges = !keepChanges
        table.reloadSections([0], with: .automatic)
        viewer?.keepFormat = keepChanges ? currentFormat : nil
        viewer?.keepQuality = keepChanges ? currentQuality : nil
    }
}


extension ManifestController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + (viewModel?.manifest.metadata?.items.first != nil ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return numberOfLines
        case 1:
            return viewModel?.metaInfoCount ?? 0
        case 2:
            return viewModel?.manifest.metadata?.items.count ?? 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isPicker = indexPath == pickerIndex
        let reuseId = (indexPath.section > 0 ? "metadataCell" : (isPicker ? "pickerCell" : (indexPath.row == numberOfLines - 1 ? "checkerCell" : "settingsCell")))
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)

        if indexPath.section == 0 {
            if isPicker {
                let picker = cell.contentView.subviews.first as! UIPickerView
                let valueIndex = IndexPath(row: indexPath.row-1, section: indexPath.section)
                let value = tableView.cellForRow(at: valueIndex)!.detailTextLabel!.text!
                let array = pickerType == titles[0] ? imageQualities : imageFormats
                let selectionIndex = array!.index(of: value)
                picker.selectRow(selectionIndex ?? 0, inComponent: 0, animated: false)
                picker.reloadAllComponents()
            } else if indexPath.row == numberOfLines - 1 {
                let checker = cell.contentView.subviews.first(where: { $0 is UISwitch }) as! UISwitch
                checker.isOn = keepChanges
            } else {
                let value = indexPath.row == 0 ? currentQuality : currentFormat
                cell.textLabel?.text = titles[indexPath.row]
                cell.detailTextLabel?.text = value ?? none
            }
        } else {
            let metadataCell = cell as! MetadataCell
            var title: String?
            var value: String?

            if indexPath.section == 1 {
                title = viewModel?.getMetaInfoKey(at: indexPath.row)
                value = viewModel?.getMetaInfo(at: indexPath.row, forLanguage: Constants.lang)
            } else {
                let item = viewModel!.manifest.metadata!.items[indexPath.row]
                title = item.getLabel(forLanguage: Constants.lang)
                value = item.getValue(forLanguage: Constants.lang)
            }

            metadataCell.fillIn(title: title, value: value)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 0 else { return nil }

        return keepChanges ? NSLocalizedString("img_keep_hint", comment: "") : nil
    }
}


extension ManifestController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0, indexPath.row != numberOfLines - 1 else {
            return
        }

        if pickerIndex != nil {
            tableView.beginUpdates()
            tableView.deleteRows(at: [pickerIndex!], with: .automatic)
            numberOfLines -= 1
            pickerIndex = nil
            tableView.endUpdates()

            pickerType = nil
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            let array = indexPath.row == 0 ? imageQualities : imageFormats
            guard cell?.detailTextLabel?.text != none, array?.count ?? 0 > 1 else {
                return
            }

            pickerType = titles[indexPath.row]
            pickerIndex = IndexPath(row: indexPath.row+1, section: indexPath.section)

            tableView.beginUpdates()
            tableView.insertRows(at: [pickerIndex!], with: UITableViewRowAnimation.automatic)
            numberOfLines += 1
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath == pickerIndex ? 110 : UITableViewAutomaticDimension
    }
}


extension ManifestController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let array = pickerType == titles[0] ? imageQualities : imageFormats
        return array?.count ?? 0
    }
}


extension ManifestController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let array = pickerType == titles[0] ? imageQualities : imageFormats
        return array![row]
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 26
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerType == titles[0] {
            let value = imageQualities![row]
            currentQuality = value
            table.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = value
            viewer?.currentQuality = currentQuality
            if keepChanges {
                viewer?.keepQuality = currentQuality
            }
        } else {
            let value = imageFormats![row]
            currentFormat = value
            table.cellForRow(at: IndexPath(row: 1, section: 0))?.detailTextLabel?.text = value
            viewer?.currentFormat = currentFormat
            if keepChanges {
                viewer?.keepFormat = currentFormat
            }
        }
    }
}
