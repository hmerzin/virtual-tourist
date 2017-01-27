//
//  Pin.swift
//  vt rewrite
//
//  Created by Harry Merzin on 1/26/17.
//  Copyright © 2017 Harry Merzin. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class Pin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    required init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
}
