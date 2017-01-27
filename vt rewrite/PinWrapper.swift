//
//  PinWrapper.swift
//  vt rewrite
//
//  Created by Harry Merzin on 1/26/17.
//  Copyright © 2017 Harry Merzin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PinWrapper: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pin: Pin
    required init(coordinate: CLLocationCoordinate2D, pin: Pin) {
        self.coordinate = coordinate
        self.pin = pin
    }

}
