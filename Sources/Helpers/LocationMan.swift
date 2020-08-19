//
//  LocationMan.swift
//  burevestnik
//
//  Created by m4rr on 8/19/20.
//

import Foundation
import CoreLocation

class LocationMan: NSObject {

  private let man = CLLocationManager()

  private var reloadUI: () -> Void = {}

  var location: CLLocation? {
    man.location
  }

  init(_ h: @escaping () -> Void) {
    super.init()

    reloadUI = h

    man.delegate = self

    defer {
      authorize()
    }
  }

  private func authorize() {

    switch CLLocationManager.authorizationStatus() {
    case .denied, .restricted:
      ()

    case .notDetermined:

      man.requestWhenInUseAuthorization()

    case .authorizedWhenInUse, .authorizedAlways:

      reloadUI()

    @unknown default:
      ()
    }

  }

}

extension LocationMan: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      reloadUI()

    default:
      ()
    }
  }

}
