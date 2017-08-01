import UIKit

fileprivate let HNTopStoriesListPath = "https://hacker-news.firebaseio.com/v0/topstories.json"
fileprivate let HNItemURLPath = ""
typealias ItemId = Int

struct API {
    
    // MARK: Private properties
    
    static let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    // MARK: Public
    
    static func fetchTopStoriesList(callback: @escaping (Result<[ItemId]>) -> Void) {
        guard let url = URL(string: HNTopStoriesListPath) else {
            fatalError()
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data")
                return
            }
            
            guard
                let json = try? JSONSerialization.jsonObject(with: data),
                let items = json as? [ItemId]
            else {
                print("No JSON")
                return
            }
            
            callback(.success(items))
        }
        
        task.resume()
    }
    
    static func fetchItem(with itemId: ItemId, callback: @escaping (Result<LoadedItem>) -> Void) {
        guard let url = itemURL(for: itemId) else {
            print("No Item")
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data")
                return
            }
            
            guard
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                let item = LoadedItem(json: json)
            else {
                print("No JSON")
                return
            }
            
            callback(.success(item))
        }
        
        task.resume()
    }
    
    static func fetchFavIcon(for item: LoadedItem, callback: @escaping (Result<UIImage>) -> Void) {
        guard
            let host = item.url.host,
            let iconURL = URL(string: "http://\(host)/favicon.ico")
        else {
            callback(failureFor(alternateMessage: NSLocalizedString("Invalid URL for Favicon", comment: "")))
            return
        }
        
        let task = session.dataTask(with: iconURL) { data, response, error in
            guard let data = data else {
                callback(failureFor(error: error, alternateMessage: NSLocalizedString("No data returned from icon fetch", comment: "")))
                return
            }
            
            guard let image = UIImage(data: data) else {
                callback(failureFor(alternateMessage: NSLocalizedString("Fetched image data is invalid", comment: "")))
                return
            }
            
            callback(.success(image))
        }
        
        task.resume()
    }
}

// MARK: Helpers

private extension API {
    
    static func itemURL(for itemId: ItemId) -> URL? {
        return URL(string: "https://hacker-news.firebaseio.com/v0/item/\(itemId).json")
    }
    
    static func failureFor<T>(error: Error? = nil, alternateMessage: String? = nil) -> Result<T> {
        return .failure(errorOrUnknown(error: error, alternateMessage: alternateMessage))
    }
    
    static func errorOrUnknown(error: Error? = nil, alternateMessage: String? = nil) -> Error {
        if let error = error {
            return error
        } else if let alternateMessage = alternateMessage {
            return ConNewsError(alternateMessage)
        } else {
            return ConNewsError.unknown
        }
    }
}

struct ConNewsError: LocalizedError {
    
    private let localizedMessage: String
    
    static let unknown = ConNewsError(NSLocalizedString("An unknown error occurred", comment: ""))
    
    init(_ localizedMessage: String) {
        self.localizedMessage = localizedMessage
    }
    
    var errorDescription: String? {
        return localizedMessage
    }
}
