// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation
import UIKit

/// Basic Delegate interface to send messages
protocol CatDataDelegate {
    func breedsChangedNotification()
    func imageChangedNotification()
}

/// View model
class ViewModel {
    private(set) var currentPage = 0
    private(set) var isLoadingBreeds = false
    var catDataDelegate: CatDataDelegate?
    
    /// Array of cat breeds
    var catBreeds: [CatBreed]? {
        didSet {
            self.catDataDelegate?.breedsChangedNotification()
        }
    }
    
    /// Image of the cat
    var catImage: UIImage? {
        didSet {
            self.catDataDelegate?.imageChangedNotification()
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
            case .success(let breeds): self.catBreeds = breeds
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
                self.catBreeds = (self.catBreeds ?? []) + breeds
            case .failure(let error):
                self.currentPage -= 1   // roll back on failure
                print(error)
            }
        }
    }
    
    func getCatImage(breedId: String) {
        Network.fetchCatImage(breedId: breedId) { (result) in
            switch result
            {
            case .success(let image):
                self.catImage = image
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
