//
//  ViewController.swift
//  QuickBin
//
//  Created by User on 11/12/18.
//  Copyright © 2018 cs325-project3. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet private var suggestButtonCollection: [UIButton]!

    private var maskView : UIView?

    private let userDataPath = "\(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])/BinSpots.plist"

    private lazy var userStoredSpots: [String : Bin] = {
        guard
            let x = NSDictionary.init(contentsOfFile: userDataPath) as? [String : [String : Any]] else { return [:]}
        return [String : Bin](uniqueKeysWithValues: zip(x.keys, x.flatMap {Bin.init($1, builtIn: false, identifier: $0)}))
    }()
    private lazy var locationManager : CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    private var locationUpdateCompletionHandler: ((CLLocationCoordinate2D) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.bool(forKey: PreferencesKeys.SplashScreenShownKey) && false {
            firstPresenting()
        }
        else {
            let view = UIView(frame: UIScreen.main.bounds)
            view.backgroundColor = .white
            view.isOpaque = true
            self.view.addSubview(view)
            self.maskView = view
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let maskView = maskView {
            self.performSegue(withIdentifier: "ToTutorial", sender: {
                self.maskView = nil
                maskView.removeFromSuperview()
                UserDefaults.standard.set(true, forKey: PreferencesKeys.SplashScreenShownKey)
                self.firstPresenting()
            })
        }
    }
    private func firstPresenting() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(CLLocation(latitude: 42.3899, longitude: -72.5286).coordinate, 500, 500)
        self.mapView.setRegion(coordinateRegion, animated: false)
        // TODO: user last used pref. and location. (Read from preferences)

        let builtInDatabase = (NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "locationData", ofType: "plist")!) as! [String : [String : Any]]).flatMap {Bin.init($1, builtIn: true, identifier: $0)}

        self.mapView.addAnnotations(builtInDatabase)
    }
    @IBAction private func locateSelf(_ sender: UIButton?) {
        guard CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways else {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            else {
                let alertView = UIAlertController(title: "Error", message: "Location Services is not available. Please go to settings and turn on location services to determine current location.", preferredStyle: .alert)
                alertView.addAction(.init(title: "OK", style: .cancel))
                self.present(alertView, animated: true)
            }
            return
        }
        if let loc = self.mapView.userLocation.location, self.locationUpdateCompletionHandler == nil {
            self.mapView.setCenter(loc.coordinate, animated: true)
        }
        else {
            self.mapView.showsUserLocation = true
        }
        self.locationManager.requestLocation()
    }

    @IBAction func showNearestBinForType(_ sender: UIButton) {
        guard let location = self.mapView.userLocation.location else {
            self.locationUpdateCompletionHandler = { [unowned self] _ in
                self.showNearestBinForType(sender)
            }
            self.locateSelf(nil)
            return
        }
        self.locationUpdateCompletionHandler = nil
        let requestedType = Bin.BinType.init(sender.tag)!
        let nearest = self.mapView.annotations.filter { annotation in
            if let bin = annotation as? Bin, bin.type == requestedType {
                return true
            }
            return false
        }.min { (bin1, bin2) -> Bool in
            location.distance(from: CLLocation(latitude: bin1.coordinate.latitude, longitude: bin1.coordinate.longitude)) < location.distance(from: CLLocation(latitude: bin2.coordinate.latitude, longitude: bin2.coordinate.longitude))
        }
        if let nearest = nearest {
            self.mapView.showAnnotations([nearest], animated: true)
            self.mapView.selectAnnotation(nearest, animated: true)
        }
        else {
            self.mapView.deselectAnnotation(self.mapView.selectedAnnotations.first, animated: true)
            // TODO: not found? A prompt?
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navi = segue.destination as? UINavigationController {
            if let addvc = navi.viewControllers.first as? AddViewController {
                addvc.delegate = self
                addvc.userLocationCoordinate = self.mapView.userLocation.location?.coordinate
                addvc.currentVisibleRegion = self.mapView.region
                addvc.editingBin = sender as? Bin
            }
            else if let rvc = navi.viewControllers.first as? ReportViewController {
                rvc.previousVC = self
            }
        }
        else if let tvc = segue.destination as? SplashPageViewController {
            tvc.finishedBlock = sender as? (() -> Void)
        }
    }
}
extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "bin"
        guard let annotation = annotation as? Bin else { return nil }
        var annotationView: BinAnnotationView
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? BinAnnotationView {
            annotationView = view
        }
        else {
            annotationView = BinAnnotationView.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.delegate = self
        }

        annotationView.annotation = annotation
        
        return annotationView
    }
}
extension ViewController : BinAnnotationViewActionDelegate {
    func directionButtonTapped(annotationView: BinAnnotationView, actionSender: UIButton) {
        let annotation = annotationView.annotation as! Bin

        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: annotationView.annotation!.coordinate, addressDictionary: [CNPostalAddressStreetKey : annotation.title!]))
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
    }

    func reportEditButtonTapped(annotationView: BinAnnotationView, actionSender: UIButton) {
        if annotationView.binAnnotation.builtIn {
            self.performSegue(withIdentifier: "ToReport", sender: nil)
        }
        else {
            self.performSegue(withIdentifier: "ToAdd", sender: annotationView.binAnnotation)
        }
    }
}
extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            return
        }
        locateSelf(nil)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("Updated Locations: \(locations.last!)")
        let userLocationCoordinate: CLLocationCoordinate2D = (locations.last?.coordinate)!
        if let handler = self.locationUpdateCompletionHandler {
            handler(userLocationCoordinate)
            self.locationUpdateCompletionHandler = nil
        }
        else {
//           self.mapView.setCenter(userLocationCoordinate, animated: true)
//            self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(, defaultSpan, defaultSpan), animated: true)
        }

    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationUpdateCompletionHandler = nil
        let alertView = UIAlertController(title: "Error", message: "Cannot determine current location. Reason: \(error.localizedDescription)", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alertView, animated: true)
    }
}
extension ViewController : AddingBinViewControllerDelegate {
    func addViewControllerCreate(_ vc: AddViewController, createdBin: Bin) {
        if let prevBin = self.userStoredSpots[createdBin.identifier] {
            self.mapView.removeAnnotation(prevBin)
        }
        self.mapView.addAnnotation(createdBin)
        self.userStoredSpots[createdBin.identifier] = createdBin
        self.mapView.showAnnotations([createdBin], animated: true)
        self.mapView.selectAnnotation(createdBin, animated: true)
        // TODO: Write data to disk.
//        saveData()
    }

    func addViewControllerDelete(_ vc: AddViewController, deletedBin: Bin) {
        self.userStoredSpots.removeValue(forKey: deletedBin.identifier)
        let annotationView = self.mapView.view(for: deletedBin)!
        let originalAlpha = annotationView.alpha
        let originalTransform = annotationView.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        annotationView.alpha = 0
                        annotationView.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)

        }) { (_) in
            self.mapView.removeAnnotation(deletedBin)
            annotationView.alpha = originalAlpha
            annotationView.transform = originalTransform
        }
        // TODO: Write data to disk.
//        saveData()
    }
//    func saveData() {
//        (self.userStoredSpots.mapValues {$0.archivedPropertyList.1} as NSDictionary).write(toFile: userDataPath, atomically: true)
//    }

}

