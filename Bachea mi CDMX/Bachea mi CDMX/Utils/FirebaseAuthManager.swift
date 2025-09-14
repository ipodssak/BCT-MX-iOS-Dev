//
//  FirebaseAuthManager.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 12/09/25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class FirebaseAuthManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        setupAuthStateListener()
    }
    
    // Configura listener para cambios de estado de autenticacion
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener {[weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isSignedIn = user != nil
            }
        }
    }
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
            isLoading = false
            errorMessage = "No se pudo obtener la vista principal"
            return
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) {[weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Error al iniciar sesion: \(error.localizedDescription)"
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self?.errorMessage = "Error al obtener el token de Google"
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self?.errorMessage = "Error al autenticar con Firebase: \(error.localizedDescription)"
                        } else {
                            self?.isSignedIn = true
                            self?.user = authResult?.user
                        }
                    }
                }
            }
        }
    }
    
    // Cerrar sesion
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            isSignedIn = false
            user = nil
        } catch {
            errorMessage = "Error al cerrar sesion: \(error.localizedDescription)"
        }
    }
}
