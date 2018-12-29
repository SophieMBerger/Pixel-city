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

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    //    Instanciating CL location manager
    var locationManager = CLLocationManager()
    //    Location Services authorization status
    let authorizationStatus = CLLocationManager.authorizationStatus()
    //    Radius of map center radius in meters
    let regionRadius: Double = 1000
    //    Activity indicator
    var spinner: UIActivityIndicatorView?
    //    Lable to indicate progress of downloading photos
    var progressLbl: UILabel?
    var screenSize = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self as MKMapViewDelegate
        locationManager.delegate = self as CLLocationManagerDelegate
        configureLocationServices()
        addDoubleTap()
    }
    
    func addDoubleTap() {
        //        passing in UITapGestureRecognizer as sender
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        //        must conform to UIGestureRecognizerDelegat
        doubleTap.delegate = self
        //        must add gesture recognizer to a view to work
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
    func addSwipe() {
        //        create UISwipeGestureRe3cognizer to close photo view
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector (animateViewDown))
        swipe.direction = .down
        //        add the gesture recognizer to the pull up view to actually be able to use it
        pullUpView.addGestureRecognizer(swipe)
    }

    @objc func animateViewDown() {
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        pullUpView.addSubview(spinner!)
    }
    
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        //        re-draws the layout after constraint change
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func centerMApBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

//Extension for MapViewDelegate
extension MapVC: MKMapViewDelegate {
//    to customize the pin view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //        do not change look of user location pin
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.6296746135, blue: 0, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    //Center map onto user location (1km radius)
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //    action for addDoubleTap func UITapGestureRecognizer
    @objc func dropPin(sender: UITapGestureRecognizer) {
        //        remove previous pins
        removePin()
        animateViewUp()
        addSwipe()
        addSpinner()
        //        create touch point to get coordinates of touch on map
        let touchPoint = sender.location(in: mapView)
        //        convert touchPoint to GPS coordinate to pass into Flickr API
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
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

