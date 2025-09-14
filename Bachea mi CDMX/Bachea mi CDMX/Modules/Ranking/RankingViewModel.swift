//
//  RankingViewModel.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 13/09/25.
//

import Foundation
import FirebaseFirestore

class RankingViewModel: ObservableObject {
    @Published var municipalities: [Municipality] = []
    @Published var statistics: GeneralStatistics = GeneralStatistics.sampleData
    @Published var selectedFilter: StateFilter = .all
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    private var statisticsListener: ListenerRegistration?
    private var municipalitiesListener: ListenerRegistration?
    
    init() {
        loadData()
        setupRealTimeListener()
    }
    
    deinit {
        statisticsListener?.remove()
        municipalitiesListener?.remove()
    }
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        firebaseService.fetchGeneralStatistics { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let statistics):
                    self?.statistics = statistics
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.statistics = GeneralStatistics.sampleData
                }
            }
        }
        
        loadMunicipalities()
    }
    
    func selectFilter(_ filter: StateFilter) {
        selectedFilter = filter
        loadMunicipalities()
    }
    
    func refreshData() {
        loadData()
    }
    
    private func loadMunicipalities() {
        isLoading = true
        errorMessage = nil
        
        switch selectedFilter {
        case .all:
            firebaseService.fetchMunicipalities { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleMunicipalitiesResult(result)
                }
            }
        case .cdmx:
            firebaseService.fetchMunicipalitiesByState("Ciudad de México") { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleMunicipalitiesResult(result)
                }
            }
        case .edomex:
            firebaseService.fetchMunicipalitiesByState("Estado de México") { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleMunicipalitiesResult(result)
                }
            }
        case .morelos:
            firebaseService.fetchMunicipalitiesByState("Morelos") { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleMunicipalitiesResult(result)
                }
            }
        }
    }
    
    private func handleMunicipalitiesResult(_ result: Result<[Municipality], Error>) {
        isLoading = false
        switch result {
        case .success(let municipalities):
            self.municipalities = Municipality.sampleData
            self.errorMessage = nil
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.municipalities = Municipality.sampleData
        }
    }
    
    private func setupRealTimeListener() {
        statisticsListener = firebaseService.listenToStatitics { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let statistics):
                    self?.statistics = statistics
                case .failure(let error):
                    print("Error listening to statistics: \(error.localizedDescription)")
                }
            }
        }
        
        municipalitiesListener = firebaseService.listenToMunicipalities { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let municipalities):
                    if self?.selectedFilter == .all {
                        self?.municipalities = municipalities
                    }
                case .failure(let error):
                    print("Error listening to municipalities: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var filteredMunicipalities: [Municipality] {
        return municipalities.sorted { $0.rank < $1.rank}
    }
    
    var leadingMunicipalityText: String {
        return "\(statistics.leadingMunicipality) lidera con \(statistics.leadingReport) reportes"
    }
}
