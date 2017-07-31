import Foundation

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
    
    static func fetchItem(with itemId: ItemId) {
        guard let url = itemURL(for: itemId) else {
            print("No Item")
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data")
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) else {
                print("No JSON")
                return
            }
            
            print("Story: \(json)")
        }
        
        task.resume()
    }
}

// MARK: Helpers

private extension API {
    
    static func itemURL(for itemId: ItemId) -> URL? {
        return URL(string: "https://hacker-news.firebaseio.com/v0/item/\(itemId).json")
    }
}
