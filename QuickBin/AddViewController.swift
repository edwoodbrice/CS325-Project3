//
//  AddViewController.swift
//  QuickBin
//
//  Created by User on 12/6/18.
//  Copyright © 2018 cs325-project3. All rights reserved.
//

import UIKit
import Photos
import MapKit

protocol AddingBinViewControllerDelegate : NSObjectProtocol {
    func addViewControllerCreate(_ vc: AddViewController, createdBin: Bin)
    func addViewControllerDelete(_ vc: AddViewController, deletedBin: Bin)
}
class AddViewController: UITableViewController {

    weak var delegate : AddingBinViewControllerDelegate?
    var userLocationCoordinate: CLLocationCoordinate2D?
    var currentVisibleRegion: MKCoordinateRegion!
    var editingBin: Bin?

    @IBOutlet private weak var binImageView: UIImageView!

    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var locationCoordinateLabel: UILabel!

    @IBOutlet private weak var currentLocationButton: UIButton!

    @IBOutlet private weak var otherLocationButton: UIButton!

    @IBOutlet private var binTypeButtonCollection: [UIButton]!
    @IBOutlet private weak var deleteButtonCell: UITableViewCell!

    @IBOutlet private weak var deleteButton: UIButton!

    private weak var selectedButton: UIButton?
    private var selectedBinLocationCoordinate: CLLocationCoordinate2D?
    private var imageForBin: UIImage?

    private var selectedType: Bin.BinType? {
        guard let tag = self.selectedButton?.tag else { return nil }
        return Bin.BinType.init(tag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer({
            let x = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyBoardByTapping(_:)))
            x.cancelsTouchesInView = false
            return x
            }()
        )

        self.currentLocationButton.setBackgroundColor(self.view.tintColor, for: .normal)
//        self.currentLocationButton.setBackgroundColor(.darkGray, for: .highlighted)
        self.otherLocationButton.setBackgroundColor(UIColor.init(white: 0.5, alpha: 0.1), for: .normal)
//        self.otherLocationButton.setBackgroundColor(.darkGray, for: .highlighted)
        if let editingBin = self.editingBin {
            self.navigationItem.title = "Edit Bin"
            self.selectedButton = self.binTypeButtonCollection.first {$0.tag == editingBin.type.numericValue}
            self.selectedButton!.setImage(UIImage(named: editingBin.type.rawValue + "-selected") , for: .normal)
            self.selectedBinLocationCoordinate = editingBin.coordinate
            if let image = editingBin.image {
                self.imageForBin = image
                self.binImageView.image = image
            }
            self.descriptionTextView.text = editingBin.subtitle
            self.deleteButton.setBackgroundColor(.red, for: .normal)
            self.updateLocationLabels()
        }
        else {
            self.deleteButtonCell.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    private func updateLocationLabels() {
        self.locationCoordinateLabel.text = String.init(format: "%.04f, %.04f", self.selectedBinLocationCoordinate!.latitude, self.selectedBinLocationCoordinate!.longitude)
    }
    @IBAction func typeButtonTapped(_ sender: UIButton) {
        guard self.selectedButton !== sender else {
            return
        }
        // TODO: placeholder for non-selected type
        self.selectedButton?.setImage(UIImage(named: Bin.BinType.init(self.selectedButton!.tag)!.rawValue + " Button"), for: .normal)
//        self.selectedButton?.setTitleColor(self.view.tintColor, for: .normal)
        self.selectedButton = sender
        sender.setImage(UIImage(named: Bin.BinType.init(sender.tag)!.rawValue + "-selected"), for: .normal)

//        sender.setTitleColor(.red, for: .normal)
    }
    @IBAction func currentLocationTapped(_ sender: UIButton) {
        // TODO: Try to fetch current location if user did not fetch before.
        guard let userLocation = self.userLocationCoordinate else {
            let alertView = UIAlertController(title: "Error", message: LocalizedString.currentLocationIsNotAvailableWhenAddBin, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alertView, animated: true)
            return
        }
        self.selectedBinLocationCoordinate = userLocation
        self.updateLocationLabels()
    }


    @IBAction func pickImageTapGesture(_ sender: UITapGestureRecognizer) {
        guard !self.descriptionTextView.isFirstResponder else {
            self.dismissKeyBoardByTapping()
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self

        let actionView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionView.addAction(UIAlertAction(title: "Take a picture", style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.getPictureFromCamera {
                    self.present(imagePickerController, animated: true)
                }
            }
            else {
                // simulator only.
                let alert = UIAlertController(title: "Error", message: "Camera is not available on this device.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
        }))
        actionView.addAction(UIAlertAction(title: "Choose from library", style: .default, handler: { (_) in
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = false
            self.getPictureFromPhotoLibrary {
                self.present(imagePickerController, animated: true)
            }
        }))
        actionView.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(actionView, animated: true)
    }
    @objc func dismissKeyBoardByTapping(_ sender: Any? = nil) {
        self.view.endEditing(true)
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismissKeyBoardByTapping()
        self.dismiss(animated: true)
    }
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        self.dismissKeyBoardByTapping()
        guard let selectedType = self.selectedType else {
            let alertView = UIAlertController(title: "Error", message: LocalizedString.userDidNotSelectATypeWhenAddBin, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alertView, animated: true)
            return
        }
        guard let loc = self.selectedBinLocationCoordinate else {
            let alertView = UIAlertController(title: "Error", message: LocalizedString.userDidNotPickLocationWhenAddBin, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alertView, animated: true)
            return
        }
        self.dismiss(animated: true) {
            self.delegate?.addViewControllerCreate(self, createdBin: Bin(selectedType, location: loc, image: self.imageForBin, subtitle: self.descriptionTextView.text, identifier: self.editingBin?.identifier))
        }
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alertView = UIAlertController(title: "Warning", message: LocalizedString.warningBeforeRemovingBin, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "No", style: .cancel))
        alertView.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            self.dismiss(animated: true, completion: {
                self.delegate?.addViewControllerDelete(self, deletedBin: self.editingBin!)
            })
        }))
        self.present(alertView, animated: true)
        return
    }
    private func getPictureFromCamera(completionHandler: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { cameraAllowed in
                if cameraAllowed {
                    DispatchQueue.main.async(execute: completionHandler)
                }
            })
        case .authorized:
            completionHandler()
        default:
            let alertView = UIAlertController(title: "Error", message: LocalizedString.permissionForCameraIsNotGiven, preferredStyle: .alert)
            alertView.addAction(.init(title: "OK", style: .cancel))
            self.present(alertView, animated: true)
        }
    }
    private func getPictureFromPhotoLibrary(completionHandler: @escaping () -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if status == PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async(execute: completionHandler)
                }
            }
        case .authorized:
            completionHandler()
        default:
            let alertView = UIAlertController(title: "Error", message: LocalizedString.permissionForPhotoLibraryIsNotGiven, preferredStyle: .alert)
            alertView.addAction(.init(title: "OK", style: .cancel))
            self.present(alertView, animated: true)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? MapViewController {
            mvc.previousRegion = self.currentVisibleRegion
            mvc.userLocationCoordinate = self.userLocationCoordinate
            mvc.selectedLocationCallback = { selectedLocation in
                print("Returned location: \(selectedLocation)")
                self.selectedBinLocationCoordinate = selectedLocation
                self.updateLocationLabels()
            }
        }
    }

}
extension AddViewController : UIImagePickerControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // considering scale it down to reduce memory usage.
            self.binImageView.image = image
            self.imageForBin = image
        }
        picker.dismiss(animated: true)
    }
}
extension AddViewController : UINavigationControllerDelegate, UITextViewDelegate {
//    func textViewDidEndEditing(_ textView: UITextView) {
//
//    }
//    func textViewDidBeginEditing(_ textView: UITextView) {
//
//    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.tableView(self.tableView, cellForRowAt: indexPath).isHidden {
            return 0
        }
        // section 3
        if indexPath.section == 2 {
            return self.view.bounds.size.width
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}
