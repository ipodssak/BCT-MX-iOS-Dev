//
//  HomeView.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 12/09/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RankingView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "star.fill" : "star")
                    Text("Ranking")
                }
                .tag(0)
            
            ProfileViewDemo()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "person.fill" : "person")
                    Text("Perfil")
                }
                .tag(1)
        }
        .accentColor(Color(red: 0.7, green: 0.5, blue: 0.9))
    }
}

struct HomeView_Previous: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
