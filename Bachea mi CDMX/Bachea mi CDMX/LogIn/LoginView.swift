//
//  LoginView.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 12/09/25.
//

import SwiftUI
import GoogleSignIn

struct LoginView: View {
    @StateObject private var authManager = FirebaseAuthManager()
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Bienvenido")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Inicia sesion para continuar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    Button(action: {
                        authManager.signInWithGoogle()
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .font(.title)
                            
                            Text("Continuar con Google")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .disabled(authManager.isLoading)
                    
                    if authManager.isLoading {
                        ProgressView("Iniciando sesion...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(authManager.errorMessage ?? "Error Desconocido")
        }
        .onChange(of: authManager.errorMessage) { errorMessage in
            if errorMessage != nil {
                showAlert = true
            }
        }
    }
}

struct LoginView_Previous: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
