//
//  Constants.swift
//  pixel-city
//
//  Created by Sophie Berger on 30.12.18.
//  Copyright © 2018 SophieMBerger. All rights reserved.
//

import Foundation

let apiKey = "49acc12eadd82b3cb1e41d9ce1bf06e5"

func flickrUrl(forApiKey Key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}


