//
//  ContentView.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 12/09/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authManager = FirebaseAuthManager()
    
    var body: some View {
        Group {
            if authManager.isSignedIn {
                HomeView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
        .onAppear{
            authManager.isSignedIn = Auth.auth().currentUser != nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
