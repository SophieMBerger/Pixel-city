//
//  MapVC.swift
//  pixel-city
//
//  Created by Sophie Berger on 25.12.18.
//  Copyright © 2018 SophieMBerger. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self as! MKMapViewDelegate
    }

    @IBAction func centerMApBtnWasPressed(_ sender: Any) {
    }
    
}

extension MapVC: MKMapViewDelegate {
    
}

