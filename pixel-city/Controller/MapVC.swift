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
import Alamofire
import AlamofireImage

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
    
    //    Collection view for photos created programatically
    var collectionView: UICollectionView?
    //    Flow layout must be added when adding collection view programatically
    var flowLayout = UICollectionViewFlowLayout()
    
    //    array holding URLs for images
    var imageUrlArray = [String]()
    //    Array to hold the images
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self as MKMapViewDelegate
        locationManager.delegate = self as CLLocationManagerDelegate
        configureLocationServices()
        addDoubleTap()
        
        //        set-up collection view
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        //        register a cell for collection view to use
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        pullUpView.addSubview(collectionView!)
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
        cancelAllSessions()
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
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            //        if there is a spinner
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
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
        removeSpinner()
        removeProgressLbl()
        cancelAllSessions()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        //        create touch point to get coordinates of touch on map
        let touchPoint = sender.location(in: mapView)
        //        convert touchPoint to GPS coordinate to pass into Flickr API
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        //Reload collection view
                    }
                })
            }
        }
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
        imageUrlArray = []
        
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in //response holds the value of the JSON we get as a response to the request
            guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
            //            parse out the photos dictionary
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
        }
    }
    
    //    needs completion handler to indicate that collection view data must be reloaded
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        imageArray = []
        
        for url in imageUrlArray {
            //Use AlamofireImage to download images (to call .responseImage)
            //Response = data response of type Image
            Alamofire.request(url).responseImage { (response) in
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                
                //Update progress label
                self.progressLbl?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
                }
            }
    }
    
    //    Cancell all downloads when user swipes pull-up view down during image download
    func cancelAllSessions() {
        //        Accessing a singleton class from Alamofire
        //        Pass-in three diferent possible sessions that can occur (as constants (arrays) into func)
        //        Not uploading data so do not need to use uploadData session task in body/closure
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            //Cancell every instance of sessionDataTask and downloadData
            //$0 = for task in sessionDataTask ... (lambda expression as $0 is generic name for task)
            sessionDataTask.forEach({ $0.cancel()})
            downloadData.forEach({$0.cancel()})
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

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        number of items in array
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
        return cell!
    }
}

