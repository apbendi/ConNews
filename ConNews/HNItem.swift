import Foundation

enum HNItem {
    case loaded(LoadedItem)
    case notLoaded(ItemId)
}

struct LoadedItem {
    
    let id: ItemId
    let title: String
    let url: URL
    
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? ItemId,
            let title = json["title"] as? String,
            let urlString = json["url"] as? String,
            let url = URL(string: urlString)
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.url = url
    }
}
