//
//  ActionViewController.swift
//  Open in IIIF
//
//  Created by Jakub Fiser on 01/03/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import MobileCoreServices
import UIKit


class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    fileprivate var operation: Operation?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the item[s] we're handling from the extension context.
        var urlFound = false
        outer:
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (item, _) in
                        if let url = item as? URL {
                            self.operation = OpenApplication(url.absoluteString, self as UIResponder)
                            OperationQueue.main.addOperation(self.operation!)
                            OperationQueue.main.addOperation({
                                self.close()
                            })
                        }
                    })

                    urlFound = true
                    break outer
                }
            }
        }

        if !urlFound {
            print("No url.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Cancel press
    @IBAction func done() {
        operation?.cancel()
        close()
    }

    fileprivate func close() {
        self.extensionContext?.completeRequest(returningItems: self.extensionContext?.inputItems, completionHandler: nil)
    }
}

class OpenApplication: Operation {

    let urlString: String
    weak var firstResponder: UIResponder?


    init(_ url: String, _ responder: UIResponder?) {
        urlString = url
        super.init()
        firstResponder = responder
    }

    override func main() {
        print("Url: \(urlString)")

        guard !isCancelled else {
            print("Canceled.")
            return
        }

        guard let url = URL(string: "iiif:" + urlString) else {
            print("Can't create url iiif:" + urlString)
            return
        }

        let context = NSExtensionContext()
        context.open(url, completionHandler: nil)
        var responder = firstResponder
        while responder != nil && !isCancelled {
            if responder!.responds(to: Selector("openURL:")) == true {
                responder!.perform(Selector("openURL:"), with: url)
                break
            }
            responder = responder!.next
        }
    }
}
