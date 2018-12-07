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
    let usersLocationAvailable = CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
    var previousRegion: MKCoordinateRegion!

    var selectedLocationCallback: ((CLLocationCoordinate2D) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = self.usersLocationAvailable
//        if let prev = self.previousRegion {
        self.mapView.setRegion(self.previousRegion, animated: false)
//        }
//        else if self.usersLocationAvailable {
//        }

        // Do any additional setup after loading the view.
    }

}
