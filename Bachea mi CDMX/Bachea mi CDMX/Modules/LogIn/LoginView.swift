//
//  LoginView.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 12/09/25.
//

import SwiftUI
import GoogleSignIn

struct LoginView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.92, blue: 0.90)
                    .ignoresSafeArea()
                VStack(spacing: 40) {
                    Spacer()
                    VStack(spacing: 40) {
                        Text("BacheaMiCiudad")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.6))
                            .multilineTextAlignment(.center)
                        Text("Reporta baches y mejora tu ciudad")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .multilineTextAlignment(.center)
                    }
                    
                    GoogleSignInButton()
                    
                    Text("Al continuar, aceptas nuestros términos y condiciones")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .preferredColorScheme(.light)
        }
        .navigationBarHidden(true)
    }
}

struct GoogleSignInButton: View {
    @StateObject private var authManager = FirebaseAuthManager()
    
    var body: some View {
        Button(action: {
            authManager.signInWithGoogle()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                    
                    HStack(spacing: 1) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                    }
                }
                
                Text("Continuar con Google")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.black)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.white)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 0.9, green: 0.85, blue: 0.95), lineWidth: 1)
            }
            .cornerRadius(8)
            .shadow(radius: 1)
            .disabled(authManager.isLoading)
        }
        .buttonStyle(PlainButtonStyle())
        
        if authManager.isLoading {
            ProgressView("Iniciando sesion...")
                .progressViewStyle(CircularProgressViewStyle())
        }
    }
}

struct LoginView_Previous: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


//VStack(spacing: 30) {
//    Spacer()
//    
//    VStack(spacing: 16) {
//        Image(systemName: "person.circle.fill")
//            .font(.system(size: 80))
//            .foregroundColor(.blue)
//        
//        Text("Bienvenido")
//            .font(.largeTitle)
//            .fontWeight(.bold)
//        
//        Text("Inicia sesion para continuar")
//            .font(.subheadline)
//            .foregroundColor(.secondary)
//    }
//    
//    Spacer()
//    
//    VStack(spacing: 20) {
//        Button(action: {
//            authManager.signInWithGoogle()
//        }) {
//            HStack {
//                Image(systemName: "globe")
//                    .font(.title)
//                
//                Text("Continuar con Google")
//                    .font(.headline)
//            }
//            .foregroundColor(.white)
//            .frame(maxWidth: .infinity)
//            .frame(height: 50)
//            .background(Color.red)
//            .cornerRadius(10)
//            .shadow(radius: 5)
//        }
//        .disabled(authManager.isLoading)
//        
//        if authManager.isLoading {
//            ProgressView("Iniciando sesion...")
//                .progressViewStyle(CircularProgressViewStyle())
//        }
//    }
//    .padding(.horizontal, 40)
//    
//    Spacer()
//}
//.padding()
//.navigationBarHidden(true)
//}
//.alert("Error", isPresented: $showAlert) {
//Button("OK") { }
//} message: {
//Text(authManager.errorMessage ?? "Error Desconocido")
//}
//.onChange(of: authManager.errorMessage) { errorMessage in
//if errorMessage != nil {
//    showAlert = true
//}
//}
//}
