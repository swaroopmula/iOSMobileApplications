import Foundation

class UniversityViewModel: ObservableObject {
    @Published var universities: [University] = []
    @Published var availableCountries: [String] = []
    @Published var availableStates: [String] = []
    @Published var selectedCountry: String = "All Countries"
    @Published var selectedState: String = "All States"
    @Published var searchText: String = ""
    @Published var sortOrder: SortOrder = .nameAsc
    
    enum SortOrder {
        case nameAsc
        case nameDesc
        case country
    }
    
    var hasActiveFilters: Bool {
        selectedCountry != "All Countries" || selectedState != "All States"
    }
    
    init() {
        loadUniversities()
    }
    
    func loadUniversities() {
        guard let url = Bundle.main.url(forResource: "uni_list", withExtension: "json") else {
            print("Could not find uni_list.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let universities = try JSONDecoder().decode([University].self, from: data)
            self.universities = universities
            
            // Get unique countries and sort them
            let countries = Set(universities.map { $0.country })
            self.availableCountries = ["All Countries"] + Array(countries).sorted()
            
            updateAvailableStates()
        } catch {
            print("Error loading universities: \(error)")
        }
    }
    
    func updateAvailableStates() {
        // Reset state selection when country changes
        selectedState = "All States"
        
        if selectedCountry == "All Countries" {
            availableStates = ["All States"]
        } else {
            // Get states only for the selected country
            let states = Set(universities
                .filter { $0.country == selectedCountry }
                .compactMap { $0.stateProvince }
                .filter { !$0.isEmpty })
            
            availableStates = ["All States"] + Array(states).sorted()
        }
    }
    
    func filteredUniversities() -> [University] {
        var filtered = universities
        
        // Filter by country
        if selectedCountry != "All Countries" {
            filtered = filtered.filter { $0.country == selectedCountry }
        }
        
        // Filter by state
        if selectedState != "All States" {
            filtered = filtered.filter { $0.stateProvince == selectedState }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.country.lowercased().contains(searchText.lowercased()) ||
                ($0.stateProvince?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        
        // Sort results
        switch sortOrder {
        case .nameAsc:
            filtered.sort { $0.name < $1.name }
        case .nameDesc:
            filtered.sort { $0.name > $1.name }
        case .country:
            filtered.sort { $0.country < $1.country }
        }
        
        return filtered
    }
} 