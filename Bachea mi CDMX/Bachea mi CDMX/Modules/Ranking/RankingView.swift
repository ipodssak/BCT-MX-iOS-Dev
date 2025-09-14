//
//  RankingView.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 13/09/25.
//

import SwiftUI

struct RankingView: View {
    @StateObject private var viewModel = RankingViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    if viewModel.isLoading {
                        LoadingView()
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                HeaderView()
                                
                                StatisticsCard(statistics: viewModel.statistics)
                                
                                FilterChips(
                                    selectedFilter: $viewModel.selectedFilter, filters: StateFilter.allCases
                                )
                                .onChange(of: viewModel.selectedFilter) { _ in
                                    viewModel.selectFilter(viewModel.selectedFilter)
                                }
                                
                                if let errorMessage = viewModel.errorMessage {
                                    ErrorView(message: errorMessage) {
                                        viewModel.refreshData()
                                    }
                                }
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.filteredMunicipalities) { municipality in
                                        MunicipalityRow(municipality: municipality)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .refreshable {
                            viewModel.refreshData()
                        }
                    }
                }
            }
        }
        .navigationTitle("Ranking")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Ranking de Alcaldias")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .multilineTextAlignment(.center)
            
            Text("Alcaldias con más reportes de todos los usuarios")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView()
    }
}
