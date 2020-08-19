//
//  Cell.swift
//  burevestnik
//
//  Created by m4rr on 8/19/20.
//

import UIKit
import MapKit

private let proximityDistance = CLLocationDistance(500)

class Cell: UITableViewCell {

  @IBOutlet weak var t1: UILabel!
  @IBOutlet weak var t2: UILabel!

}

class MapWrapperView: UIView {

  @IBOutlet private weak var mapView: MKMapView!

  func update(with loc: CLLocation?) {
    if let loc = loc?.coordinate {
      let reg = MKCoordinateRegion(center: loc,
                                   latitudinalMeters: proximityDistance,
                                   longitudinalMeters: proximityDistance)

      DispatchQueue.main.async {
        self.mapView.showsUserLocation = true
        self.mapView.setRegion(reg, animated: true)
      }
    } else {
      mapView.showsUserLocation = false
    }

  }

}
