// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation
import UIKit

/// Network interface
class Network {
    
    /// Errors from network responses
    ///
    /// - badUrl: URL could not be created
    /// - responseError: The request was unsuccessful due to an error
    /// - responseNoData: The request returned no usable data
    enum NetworkError: Int {
        case badUrl
        case responseError
        case responseNoData
        case decodeError
    }
    
    /// FetchCatBreeds - retrieve a list of cat breeds from The Cat API
    ///
    /// - Parameters
    ///   page - current page number to retrieve
    ///   completion: Closure that returns CatBreed on success, an Error on failure
    ///
    class func fetchCatBreeds(page: Int, completion: @escaping (Swift.Result<[CatBreed], Error>) -> Void) {
        
        /// Create the URL for the request
        guard let url = URL(string: "https://api.thecatapi.com/v1/breeds?limit=20&page=\(page)") else {
            let error = NSError(domain: "Network.fetchCats", code: NetworkError.badUrl.rawValue, userInfo: nil)
            return completion(Result.failure(error))
        }
        
        /// Start a data task for the URL
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            /// Check against errors
            guard error == nil else {
                let error = NSError(domain: "Network.fetchCats", code: NetworkError.responseError.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }
            
            /// Check for non-nil response data
            guard let data = data else {
                let error = NSError(domain: "Network.fetchCats", code: NetworkError.responseNoData.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }
            
            do {
                let breeds: [CatBreed]
                
                /// Decode the JSON response into a CatBreed object array
                breeds = try JSONDecoder().decode([CatBreed].self, from: data)
                
                /// Return the data
                completion(.success(breeds))

            } catch {
                /// Unable to decode the response
                let error = NSError(domain: "Network.decode", code: NetworkError.decodeError.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }
        }.resume()
    }
    
    /// Fetch a cat image
    /// - Parameters:
    ///   - breedId: The breed ID (retrieved from the `fetchCatBreeds` call
    ///   - completion: Returns a UIImage or Error
    class func fetchCatImage(breedId: String, completion: @escaping (Swift.Result<UIImage, Error>) -> Void) {

        guard let url = URL(string: "https://api.thecatapi.com/v1/images/search?breed_ids=\(breedId)&include_breeds=true") else {
            let error = NSError(domain: "Network.fetchCatDetails", code: NetworkError.badUrl.rawValue, userInfo: nil)
            return completion(Result.failure(error))
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard error == nil else {
                let error = NSError(domain: "Network.fetchCatDetails", code: NetworkError.responseError.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }
            
            guard let data = data else {
                let error = NSError(domain: "Network.fetchCatDetails", code: NetworkError.responseNoData.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }
            
            do {
                let catDetails: [CatDetails]
                
                catDetails = try JSONDecoder().decode([CatDetails].self, from: data)
                
                guard let catDetailImageUrl = catDetails.first?.url else {
                    let error = NSError(domain: "Network.fetchCatDetails", code: NetworkError.responseNoData.rawValue, userInfo: nil)
                    return completion(Result.failure(error))
                }
                
                guard let catImageUrl = URL(string: catDetailImageUrl) else {
                    let error = NSError(domain: "Network.fetchCatDetails", code: NetworkError.responseNoData.rawValue, userInfo: nil)
                    return completion(Result.failure(error))
                }
                
                let imageData = try Data(contentsOf: catImageUrl)
                
                guard let image = UIImage(data: imageData) else {
                    let error = NSError(domain: "Network.fetchCatDetails", code: NetworkError.responseNoData.rawValue, userInfo: nil)
                    return completion(Result.failure(error))
                }
                
                completion(.success(image))

            } catch {

                let error = NSError(domain: "Network.decode", code: NetworkError.decodeError.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }

        }.resume()
    }
}
