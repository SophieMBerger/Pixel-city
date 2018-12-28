//
//  droppablePin.swift
//  pixel-city
//
//  Created by Sophie Berger on 28.12.18.
//  Copyright © 2018 SophieMBerger. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    //    coordinate must be dynamic var (can be modified in necessary way)
    dynamic var coordinate: CLLocationCoordinate2D
    //    used to view pin on screen
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
