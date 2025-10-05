//
//  ProfileViewModel.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 14/09/25.
//

import Foundation
import SwiftUI
import CoreMotion
import CoreLocation

@MainActor
class ProfileViewModel: NSObject, ObservableObject {
    @Published var shakeSensitivity: ShakeSensitivity
    @Published var showingShakeSettings = false
    @Published var savedLocations: [LocationData] = []
    
    private let motionManager = CMMotionManager()
    private let locationManager = CLLocationManager()
    private var lastShakeTime = Date()
    private let shakeCooldown: TimeInterval = 2.0
    
    private let userDefaults = UserDefaults.standard
    private let saveLocationsKey = "SavedLocations"
    private let shakeSensitivityKey = "ShakeSensitivity"
    
    override init() {
        let savedSensitivity = UserDefaults.standard.string(forKey: "ShakeSensitivity") ?? ShakeSensitivity.normal.rawValue
        let shakeSensitivity = ShakeSensitivity(rawValue: savedSensitivity) ?? .normal
        self.shakeSensitivity = ShakeSensitivity.normal
        super.init()
        setupMotionManager()
        setupLocationManager()
        loadSavedLocations()
    }
    
    private func setupMotionManager() {
        motionManager.accelerometerUpdateInterval = 0.1
        startAccelerometerUpdates()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func startAccelerometerUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data else { return }
                self.detectShake(acceleration: data.userAcceleration)
            }
        }
    }
    
    private func detectShake(acceleration: CMAcceleration) {
        let accelerationMagnitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
        
        if accelerationMagnitude > shakeSensitivity.threshold {
            let now = Date()
            if now.timeIntervalSince(lastShakeTime) > shakeCooldown {
                lastShakeTime = now
                handleShakeDetected()
            }
        }
    }
    
    private func handleShakeDetected() {
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.requestLocation()
            }
        }
    }
    
    func updateShakeSensitivity(_ sensitivity: ShakeSensitivity) {
        shakeSensitivity = sensitivity
        UserDefaults.standard.set(sensitivity.rawValue, forKey: shakeSensitivityKey)
    }
    
    private func saveLocation(_ location: CLLocation) {
        let locationData = LocationData(
            latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, sensitivity: shakeSensitivity
        )
        
        savedLocations.append(locationData)
        saveLocationsToUserDefaults()
        
        print("Location saved: \(locationData.latitude), \(locationData.longitude) at \(locationData.timestamp)")
    }
    
    private func saveLocationsToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(savedLocations) {
            userDefaults.set(encoded, forKey: saveLocationsKey)
        }
    }
    
    private func loadSavedLocations() {
        if let data = userDefaults.data(forKey: saveLocationsKey), let decoded = try? JSONDecoder().decode([LocationData].self, from: data) {
            savedLocations = decoded
        }
    }
}

extension ProfileViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        saveLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location error")
    }
}
