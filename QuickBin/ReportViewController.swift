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

        // Do any additional setup after loading the view.
    }

    @IBAction func cancelReport(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    @IBAction func submitReport(_ sender: UIBarButtonItem) {
        guard let selectedRow = self.tableView.indexPathForSelectedRow else {
            let alertView = UIAlertController(title: "Error", message: "You must select a reason to report.", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alertView, animated: true)
            return
        }
        guard selectedRow.row != 2 || !self.textView.text.isEmpty else {
            let alertView = UIAlertController(title: "Error", message: "You must explain in comment if you choose other reasons.", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alertView, animated: true)
            return
        }
        self.dismiss(animated: true) {
            let alertView = UIAlertController(title: "Success", message: "The report is submitted. Thank you.", preferredStyle: .alert)
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
