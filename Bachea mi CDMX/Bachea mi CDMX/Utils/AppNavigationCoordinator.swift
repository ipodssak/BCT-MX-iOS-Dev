//
//  AppNavigationCoordinator.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 14/09/25.
//

import SwiftUI
import FirebaseAuth
import CoreLocation
import Combine

class AppNavigationCoordinator: ObservableObject {
    // Estados de navegación
    @Published var currentView: AppView = .loading
    @Published var showLocationPermission = false
    @Published var hasLocationPermission = false
    
    // Managers
    @Published var authManager = FirebaseAuthManager()
    
    enum AppView {
        case loading
        case login
        case locationPermission
        case home
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateListener()
        checkLocationPermission()
    }
    
    private func setupAuthStateListener() {
        authManager.$isSignedIn
            .sink { [weak self] isSignedIn in
                DispatchQueue.main.async {
                    if isSignedIn {
                        self?.handleSuccessfulLogin()
                    } else {
                        self?.currentView = .login
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkLocationPermission() {
        // Verificar permisos de forma asíncrona para evitar bloqueo de UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let status = CLLocationManager().authorizationStatus
            let hasPermission = status == .authorizedWhenInUse || status == .authorizedAlways
            
            DispatchQueue.main.async {
                self?.hasLocationPermission = hasPermission
            }
        }
    }
    
    func handleSuccessfulLogin() {
        // Después del login exitoso, verificar permisos de ubicación
        checkLocationPermission()
        
        if hasLocationPermission {
            // Ya tiene permisos, ir directo al Home
            currentView = .home
        } else {
            // No tiene permisos, verificar si ya fue solicitado anteriormente de forma asíncrona
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                let hasRequestedLocationPermission = UserDefaults.standard.bool(forKey: "hasRequestedLocationPermission")
                let locationManager = CLLocationManager()
                let systemHasRequestedBefore = locationManager.authorizationStatus != .notDetermined
                
                DispatchQueue.main.async {
                    if hasRequestedLocationPermission || systemHasRequestedBefore {
                        // Ya se solicitó antes (en nuestra app o en el sistema), ir directo al Home
                        self.currentView = .home
                    } else {
                        // Primera vez, mostrar vista de permisos
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.currentView = .locationPermission
                        }
                    }
                }
            }
        }
    }
    
    func onLocationPermissionGranted() {
        hasLocationPermission = true
        // Marcar que ya se solicitó el permiso
        UserDefaults.standard.set(true, forKey: "hasRequestedLocationPermission")
        currentView = .home
    }
    
    func onLocationPermissionSkipped() {
        hasLocationPermission = false
        // Marcar que ya se solicitó el permiso (aunque se omitió)
        UserDefaults.standard.set(true, forKey: "hasRequestedLocationPermission")
        currentView = .home
    }
    
    func signOut() {
        authManager.signOut()
        currentView = .login
        hasLocationPermission = false
    }
    
    // Método para resetear la preferencia de permisos (útil para testing)
    func resetLocationPermissionPreference() {
        UserDefaults.standard.removeObject(forKey: "hasRequestedLocationPermission")
    }
}
