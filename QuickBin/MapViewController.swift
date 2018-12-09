//
//  MapViewController.swift
//  QuickBin
//
//  Created by User on 12/7/18.
//  Copyright © 2018 cs325-project3. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: NavigationBarAttachedViewController {

    @IBOutlet weak var mapView: MKMapView!
//    let usersLocationAvailable = CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
    var previousRegion: MKCoordinateRegion!
    var userLocationCoordinate: CLLocationCoordinate2D?
    var selectedLocationCallback: ((CLLocationCoordinate2D) -> Void)!

    private var selectedAnnotation: MKPointAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let userLoc = self.userLocationCoordinate {
            self.mapView.showsUserLocation = true
            self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(userLoc, 50, 50), animated: false)
        }
        else {
            self.mapView.setRegion(self.previousRegion, animated: false)
        }

        // Do any additional setup after loading the view.
    }
    @IBAction private func tapToDropPin(_ sender: UITapGestureRecognizer) {
        if let annotationOnScreen = self.selectedAnnotation {
            self.mapView.removeAnnotation(annotationOnScreen)
        }
        let pinPoint = self.mapView.convert(sender.location(in: sender.view), toCoordinateFrom: self.mapView)  //sender.view?.convert(, from: sender.view)

        self.selectedAnnotation = MKPointAnnotation()
        self.selectedAnnotation!.coordinate = pinPoint
        self.mapView.addAnnotation(self.selectedAnnotation!)
    }
    @IBAction func finishedSelectingNewLocation(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
        if let selectedLocation = self.selectedAnnotation?.coordinate {
            self.selectedLocationCallback(selectedLocation)
        }
    }
}
extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {
            return nil
        }
        let reuseIdentifier = "loc"

        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView  {
            return view
        }
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        annotationView.animatesDrop = true
        return annotationView
    }
}



