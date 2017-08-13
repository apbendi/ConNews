import UIKit

fileprivate let HNTopStoriesListPath = "https://hacker-news.firebaseio.com/v0/topstories.json"
fileprivate let HNItemURLPath = ""
typealias StoryId = Int

struct API {
    
    // MARK: Private properties
    
    static let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    // MARK: Public
    
    static func fetchTopStoriesList(callback: @escaping (Result<[StoryId]>) -> Void) {
        guard let url = URL(string: HNTopStoriesListPath) else {
            fatalError("Invalid Story List URL")
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                callback(failure(for: error, alternateMessage: NSLocalizedString("No data returned from story list fetch", comment: "")))
                return
            }
            
            guard
                let json = try? JSONSerialization.jsonObject(with: data),
                let items = json as? [StoryId]
            else {
                callback(failure(alternateMessage: NSLocalizedString("Fetched Story List data is invalid", comment: "")))
                return
            }
            
            callback(.success(items))
        }
        
        task.resume()
    }
    
    static func fetchStory(with itemId: StoryId, callback: @escaping (Result<LoadedStory>) -> Void) {
        guard let url = itemURL(for: itemId) else {
            print("No Item")
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                callback(failure(for: error, alternateMessage: NSLocalizedString("No data returned from story fetch", comment: "")))
                return
            }
            
            guard
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                let item = LoadedStory(json: json)
            else {
                callback(failure(alternateMessage: NSLocalizedString("Fetched Story data is invalid", comment: "")))
                return
            }
            
            callback(.success(item))
        }
        
        task.resume()
    }
    
    static func fetchFavIcon(for item: LoadedStory, callback: @escaping (Result<UIImage>) -> Void) {
        guard
            let host = item.url.host,
            let iconURL = URL(string: "http://\(host)/favicon.ico")
        else {
            callback(failure(alternateMessage: NSLocalizedString("Invalid URL for Favicon", comment: "")))
            return
        }
        
        let task = session.dataTask(with: iconURL) { data, response, error in
            guard let data = data else {
                callback(failure(for: error, alternateMessage: NSLocalizedString("No data returned from icon fetch", comment: "")))
                return
            }
            
            guard let image = UIImage(data: data) else {
                callback(failure(alternateMessage: NSLocalizedString("Fetched image data is invalid", comment: "")))
                return
            }
            
            callback(.success(image))
        }
        
        task.resume()
    }
}

// MARK: Helpers

private extension API {
    
    static func itemURL(for itemId: StoryId) -> URL? {
        return URL(string: "https://hacker-news.firebaseio.com/v0/item/\(itemId).json")
    }
    
    static func failure<T>(for error: Error? = nil, alternateMessage: String? = nil) -> Result<T> {
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
