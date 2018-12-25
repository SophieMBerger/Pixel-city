//
//  MapVC.swift
//  pixel-city
//
//  Created by Sophie Berger on 25.12.18.
//  Copyright © 2018 SophieMBerger. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    //    Instanciating CL location manager
    var locationManager = CLLocationManager()
    //    Location Services authorization status
    let authorizationStatus = CLLocationManager.authorizationStatus()
    //    Radius of map center radius in meters
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self as MKMapViewDelegate
        locationManager.delegate = self as CLLocationManagerDelegate
        configureLocationServices()
    }

    @IBAction func centerMApBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

//Extension for MapViewDelegate
extension MapVC: MKMapViewDelegate {
//Center map onto user location (1km radius)
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

//Extension for CoreLocationDelegate (Location Services)
extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        //Check if app is authorized to get user location, if not request it, if yes simply return
        if authorizationStatus == .notDetermined {
            //Request access to location "always" (app running or not)
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    //    called whenever location services auth. is changed
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}

