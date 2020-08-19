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

  private var reloadUI: (CLLocation?) -> Void = {_ in}

  var location: CLLocation? {
    man.location
  }

  init(_ h: @escaping (CLLocation?) -> Void) {
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
      ()
//      DispatchQueue.main.async(execute: reloadUI)

    @unknown default:
      ()
    }

  }

}

extension LocationMan: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      
      manager.requestLocation()

    default:
      ()
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

      DispatchQueue.main.async {
        self.reloadUI(locations.last)
      }

    
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    debugPrint(error.localizedDescription, (error as? CLError)?.code)
  }

}
