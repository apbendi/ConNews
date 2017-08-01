import UIKit

enum HNItem {
    case loaded(LoadedItem)
    case notLoaded(ItemId)
}

struct LoadedItem {
    
    let id: ItemId
    let title: String
    let url: URL
    var icon: UIImage? = nil
    
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? ItemId,
            let title = json["title"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        
        let urlString = json["url"] as? String ?? "https://news.ycombinator.com/item?id=\(id)"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        self.url = url
    }
}
