//
//  LocationPermissionView.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 14/09/25.
//

import SwiftUI
import CoreLocation

struct LocationPermissionView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var showingSettings = false
    @State private var isRequestingPermission = false
    let onPermissionGranted: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                Color(red: 0.95, green: 0.92, blue: 0.90)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Contenido principal
                    ScrollView {
                        VStack(spacing: 30) {
                            Spacer(minLength: 40)
                            
                            // Icono de ubicación grande
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.6, green: 0.3, blue: 0.8))
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 50, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                // Título
                                Text("Permisos de Ubicación")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                
                                // Descripción
                                Text("Para brindarte la mejor experiencia, necesitamos acceso a tu ubicación")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Sección de beneficios
                            VStack(alignment: .leading, spacing: 20) {
                                Text("¿Qué podrás hacer?")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 16) {
                                    FeatureRow(
                                        icon: "location.fill",
                                        title: "Reportar Baches Automáticamente",
                                        description: "Tu ubicación se detectará automáticamente al reportar un bache"
                                    )
                                    
                                    FeatureRow(
                                        icon: "location.fill",
                                        title: "Ubicaciones Precisas",
                                        description: "Los reportes tendrán coordenadas exactas para mejor seguimiento"
                                    )
                                    
                                    FeatureRow(
                                        icon: "location.fill",
                                        title: "Mapa Interactivo",
                                        description: "Ver tu ubicación y la de otros reportes en tiempo real"
                                    )
                                    
                                    FeatureRow(
                                        icon: "location.fill",
                                        title: "Historial de Ubicaciones",
                                        description: "Guardar automáticamente los lugares donde has estado"
                                    )
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            Spacer(minLength: 40)
                        }
                    }
                    
                    // Botones de acción
                    VStack(spacing: 16) {
                        // Botón principal - Conceder Permisos
                        Button(action: {
                            handlePermissionRequest()
                        }) {
                            HStack {
                                if isRequestingPermission {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isRequestingPermission ? "Solicitando..." : "Conceder Permisos")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.6, green: 0.3, blue: 0.8))
                            .cornerRadius(12)
                        }
                        .disabled(isRequestingPermission)
                        .padding(.horizontal, 20)
                        
                        // Botón secundario - Configurar Más Tarde
                        Button(action: {
                            onSkip()
                        }) {
                            Text("Configurar Más Tarde")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.8))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.6, green: 0.3, blue: 0.8), lineWidth: 2)
                                )
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // Texto de disclaimer
                        Text("Puedes cambiar estos permisos en cualquier momento desde la configuración de tu dispositivo")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                    }
                    .background(Color.white)
                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            handleAuthorizationChange(status)
        }
        .alert("Permisos de Ubicación", isPresented: $showingSettings) {
            Button("Ir a Configuración") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Para usar esta función, necesitas habilitar los permisos de ubicación en la configuración de tu dispositivo.")
        }
    }
    
    private func handlePermissionRequest() {
        isRequestingPermission = true
        
        // Verificar el estado actual antes de proceder
        let currentStatus = locationManager.authorizationStatus
        print("🔍 Estado actual de permisos: \(currentStatus.rawValue)")
        
        switch currentStatus {
        case .notDetermined:
            print("📱 Solicitando permisos de ubicación...")
            // Solicitar permisos del sistema directamente
            locationManager.requestLocationPermission()
        case .denied, .restricted:
            print("❌ Permisos denegados, mostrando configuración")
            // Mostrar alert para ir a configuración
            isRequestingPermission = false
            showingSettings = true
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Ya tiene permisos, yendo al Home")
            // Ya tiene permisos, ir al Home
            isRequestingPermission = false
            onPermissionGranted()
        @unknown default:
            print("❓ Estado desconocido, solicitando permisos...")
            // Solicitar permisos del sistema
            locationManager.requestLocationPermission()
        }
    }
    
    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        isRequestingPermission = false
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Usuario concedió permisos, ir al Home
            onPermissionGranted()
        case .denied, .restricted:
            // Usuario denegó permisos, pero aún así ir al Home
            onSkip()
        case .notDetermined:
            // Aún no se ha tomado una decisión, mantener en la vista
            break
        @unknown default:
            // Caso desconocido, ir al Home
            onSkip()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icono
            ZStack {
                Circle()
                    .fill(Color(red: 0.6, green: 0.3, blue: 0.8))
                    .frame(width: 24, height: 24)
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Contenido
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    LocationPermissionView(
        onPermissionGranted: {
            print("Permisos concedidos")
        },
        onSkip: {
            print("Configurar más tarde")
        }
    )
}
