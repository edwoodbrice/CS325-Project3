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

    private let defaultSpan: Double = 500

    private lazy var userStoredSpots: [String : Bin] = {
        guard
            let x = NSDictionary.init(contentsOfFile: "\(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])/BinSpots.plist") as? [String : [String : Any]] else { return [:]}
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
        if UserDefaults.standard.bool(forKey: PreferencesKeys.SplashScreenShownKey) || true {
            firstPresenting()
        }
        else {
            print("Showing splash page...")
        }

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    private func firstPresenting() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(CLLocation(latitude: 42.3899, longitude: -72.5286).coordinate, defaultSpan, defaultSpan)
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
        self.mapView.showsUserLocation = true
        self.locationManager.requestLocation()
    }

    @IBAction func showNearestBinForType(_ sender: UIButton) {
        guard let location = self.mapView.userLocation.location else {
            self.locateSelf(nil)
            self.locationUpdateCompletionHandler = { _ in
                self.showNearestBinForType(sender)
            }
            return
        }
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
    @IBOutlet weak var showNearestBinForType: UIButton!


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
        self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(userLocationCoordinate, defaultSpan, defaultSpan), animated: true)
        self.locationUpdateCompletionHandler?(userLocationCoordinate)
        self.locationUpdateCompletionHandler = nil
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
        // TODO: Write data to disk.
    }

    func addViewControllerDelete(_ vc: AddViewController, deletedBin: Bin) {
        self.mapView.removeAnnotation(deletedBin)
        self.userStoredSpots.removeValue(forKey: deletedBin.identifier)
        // TODO: Write data to disk.
    }

}

