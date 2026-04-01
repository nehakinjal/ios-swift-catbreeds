// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation

/// Basic Delegate interface to send messages
protocol CatDataDelegate {
    func breedsChangedNotification()
}

/// View model
class ViewModel {
    private(set) var currentPage = 0
    private(set) var isLoadingBreeds = false
    var catDataDelegate: CatDataDelegate?

    /// All breeds fetched from the network (paginated).
    private(set) var allBreeds: [CatBreed] = [] {
        didSet {
            self.catDataDelegate?.breedsChangedNotification()
        }
    }

    /// User-entered filter; substring match on breed name (case-insensitive).
    var nameFilter: String = "" {
        didSet {
            self.catDataDelegate?.breedsChangedNotification()
        }
    }

    /// Breeds to show: `allBreeds` filtered by `nameFilter`.
    var displayBreeds: [CatBreed] {
        let q = nameFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            return allBreeds
        }
        return allBreeds.filter { breed in
            guard let name = breed.name else { return false }
            return name.localizedStandardContains(q)
        }
    }

    /// Get the breeds
    func getBreeds() {
        guard !isLoadingBreeds else { return }
        isLoadingBreeds = true
        currentPage = 0
        Network.fetchCatBreeds(page: currentPage) { result in
            self.isLoadingBreeds = false
            switch result {
            case .success(let breeds): self.allBreeds = breeds
            case .failure(let error): print(error)
            }
        }
    }

    /// Get more breeds
    func getMoreBreeds() {
        guard !isLoadingBreeds else { return }
        isLoadingBreeds = true
        currentPage += 1

        Network.fetchCatBreeds(page: currentPage) { result in
            self.isLoadingBreeds = false
            switch result {
            case .success(let breeds):
                self.allBreeds = self.allBreeds + breeds
            case .failure(let error):
                self.currentPage -= 1   // roll back on failure
                print(error)
            }
        }
    }
}
