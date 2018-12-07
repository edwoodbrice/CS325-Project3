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

    private lazy var locationManager : CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()

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
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(CLLocation(latitude: 42.3899, longitude: -72.5286).coordinate, 500, 500)
        mapView.setRegion(coordinateRegion, animated: false)
        // TODO: user last used pref. and location. (Read from preferences)
        // TODO: user saved bins. (Read from saved database)
        let builtInDatabase = (NSArray.init(contentsOfFile: Bundle.main.path(forResource: "locationData", ofType: "plist")!) as! [[String : Any]]).flatMap {Bin.init($0)}
        
        mapView.addAnnotations(builtInDatabase)

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
        mapView.showsUserLocation = true
        locationManager.requestLocation()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addvc = segue.destination as? AddViewController {
            addvc.delegate = self
            addvc.userLocationCoordinate = self.mapView.userLocation.coordinate
            addvc.currentVisibleRegion = self.mapView.region
        }
    }
}
extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "bin"
        guard let binAnnotation = annotation as? Bin else { return nil }
        var annotationView: BinAnnotationView
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? BinAnnotationView {
            annotationView = view
        }
        else {
            annotationView = BinAnnotationView.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.delegate = self
        }
        annotationView.image = binAnnotation.annotationImage
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
        print("TODO: Report page")
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
        self.mapView.setRegion(MKCoordinateRegionMakeWithDistance((locations.last?.coordinate)!, 500, 500), animated: true)

    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
extension ViewController : AddingBinViewControllerDelegate {
    func addViewControllerReturn(_ vc: AddViewController, createdBin: Bin) {
        // TODO: Show created bin.
    }
}

