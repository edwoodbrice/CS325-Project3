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
    func addViewControllerReturn(_ vc: AddViewController, createdBin: Bin)
}
class AddViewController: NavigationBarAttachedViewController {

//    private lazy var imagePickerController: UIImagePickerController = {
//        let pickerController = UIImagePickerController()
//        pickerController.delegate = self
//        return pickerController
//    }()

    weak var delegate : AddingBinViewControllerDelegate?
    var userLocationCoordinate: CLLocationCoordinate2D!
    var currentVisibleRegion: MKCoordinateRegion!
    var selectedBinLocationCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }

    @IBAction private func pickImageButtonTapped(_ sender: UIButton) {
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
    @IBAction func cancelAddingBin(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            // TODO: create a bin.
//            self.delegate?.addViewControllerReturn(self, createdBin: Bin(.Recycle, location: self.selectedBinLocationCoordinate ?? userLocationCoordinate, image: "<#T##UIImage?#>", subtitle: "<#T##String?#>"))
        }
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
            let alertView = UIAlertController(title: "Error", message: "The permission to access camera is not given. ", preferredStyle: .alert)
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
            let alertView = UIAlertController(title: "Error", message: "The permission to access photo library is not given. ", preferredStyle: .alert)
            alertView.addAction(.init(title: "OK", style: .cancel))
            self.present(alertView, animated: true)
        }
    }

/*
    private func choosePicture(from source: UIImagePickerControllerSourceType, completionHandler: @escaping () -> Void) {

//        AVCaptureDevice.authorizationStatus(for: .audio)
//        let authorizationStatus = source == .camera ? AVCaptureDevice.authorizationStatus(for: .video) :


//        switch PHPhotoLibrary.authorizationStatus() {
//        case .notDetermined:
//            PHPhotoLibrary.requestAuthorization { status in
//                if status == PHAuthorizationStatus.authorized {
//                    pickingHandler()
//                }
//            }
//        case .authorized:
//            pickingHandler()
//        default:
//            let alertView = UIAlertController(title: "Error", message: "The permission to access photo library is not given. ", preferredStyle: .alert)
//            alertView.addAction(.init(title: "OK", style: .cancel))
//            self.present(alertView, animated: true)
//        }
    }
*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? MapViewController {
            mvc.previousRegion = self.currentVisibleRegion
            mvc.selectedLocationCallback = { selectedLocation in
                // TODO: update textlabel if necessary.
                 selectedLocation
            }
        }
    }

}
extension AddViewController : UIImagePickerControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("picked image: \(image)")
        }
        picker.dismiss(animated: true)
    }
}
extension AddViewController : UINavigationControllerDelegate {

}
