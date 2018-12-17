//
//  ReportViewController.swift
//  QuickBin
//
//  Created by User on 12/8/18.
//  Copyright © 2018 cs325-project3. All rights reserved.
//

import UIKit

class ReportViewController: UITableViewController {

    @IBOutlet weak var textView: UITextView!

    weak var previousVC: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer({
            let x = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyBoardByTapping(_:)))
            x.cancelsTouchesInView = false
            return x
            }()
        )

        // Do any additional setup after loading the view.
    }

    @objc func dismissKeyBoardByTapping(_ sender: Any? = nil) {
        self.view.endEditing(true)
    }
    @IBAction func cancelReport(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    @IBAction func submitReport(_ sender: UIBarButtonItem) {
        guard let selectedRow = self.tableView.indexPathForSelectedRow else {
            let alertView = UIAlertController(title: "Error", message: LocalizedString.userDidNotSelectAnyReasonsWhenReportABin, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alertView, animated: true)
            return
        }
        guard selectedRow.row != 2 || !self.textView.text.isEmpty else {
            let alertView = UIAlertController(title: "Error", message: LocalizedString.userDidNotTypeAnythingInCommentWhenOtherIsSelectedWhenReport, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alertView, animated: true)
            return
        }
        self.dismiss(animated: true) {
            let alertView = UIAlertController(title: "Success", message: LocalizedString.reportSubmittedSuccessfullyPrompt, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .cancel))

            self.previousVC.present(alertView, animated: true)
            print("DEBUG: selected: \(selectedRow.row). Additional comment: \(self.textView.text)")
        }
    }

}
extension ReportViewController : UITextViewDelegate {
    static let placeholder = "placeholder"
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        <#code#>
//    }
//    func textViewDidEndEditing(_ textView: UITextView) {
//        <#code#>
//    }
}
