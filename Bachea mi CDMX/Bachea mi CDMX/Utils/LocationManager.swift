//
//  LocationManager.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 14/09/25.
//

import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        print("🚀 LocationManager: Solicitando permisos de ubicación...")
        print("🚀 Estado actual: \(locationManager.authorizationStatus.rawValue)")
        
        // Solicitar permisos directamente en el main thread
        // requestWhenInUseAuthorization() debe llamarse en el main thread
        locationManager.requestWhenInUseAuthorization()
        
        print("🚀 Solicitud enviada al sistema")
    }
    
    // Verificar si los permisos ya fueron solicitados anteriormente
    func hasRequestedPermissionBefore() -> Bool {
        let status = locationManager.authorizationStatus
        return status != .notDetermined
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        isLocationEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error de ubicación: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔄 LocationManager: Cambio de autorización detectado")
        print("🔄 Estado anterior: \(self.authorizationStatus.rawValue)")
        print("🔄 Estado nuevo: \(status.rawValue)")
        
        DispatchQueue.main.async {
            self.authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                print("✅ Permisos concedidos")
                self.isLocationEnabled = true
                self.startLocationUpdates()
            case .denied, .restricted:
                print("❌ Permisos denegados o restringidos")
                self.isLocationEnabled = false
            case .notDetermined:
                print("❓ Permisos no determinados")
                self.isLocationEnabled = false
            @unknown default:
                print("❓ Estado desconocido")
                break
            }
        }
    }
}
