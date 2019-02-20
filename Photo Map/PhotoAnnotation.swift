//
//  PhotoAnnotation.swift
//  Photo Map
//
//  Created by Youssef Elabd on 2/20/19.
//  Copyright © 2019 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!

    var title: String? {
        return "\(coordinate.latitude)"
    }
}
