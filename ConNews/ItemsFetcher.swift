import UIKit

final class ItemsFetcher {
    
    fileprivate(set) var items: [HNItem] {
        didSet {
            updateCallback()
        }
    }
    
    fileprivate let fetchQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 4
        
        return queue
    }()
    
    fileprivate let updateCallback: () -> Void
    
    init(_ itemIds: [ItemId], onUpdate callback: @escaping () -> Void) {
        items = itemIds.map({ return HNItem.notLoaded($0) })
        updateCallback = callback
        updateCallback()
    }
    
    func start() {
        for index in 0..<items.count {
            guard case .notLoaded(let itemId) = items[index] else {
                return
            }
            
            let fetchOp = StoryFetchOperation(with: itemId)
            fetchOp.completionBlock = {
                guard let item = fetchOp.fetchedItem else {
                    return
                }
                
                print("Fetched Story: \(item)")
                
                objc_sync_enter(self)
                self.items[index] = .loaded(item)
                objc_sync_exit(self)
            }
            
            let iconOp = IconFetchOperation()
            iconOp.addDependency(fetchOp)
            
            iconOp.completionBlock = {
                let icon = iconOp.fetchedIcon ?? #imageLiteral(resourceName: "Placeholder")
                
                print("Fetched Favicon! \(icon)")
                
                objc_sync_enter(self)
                if case .loaded(var item) = self.items[index] {
                    item.icon = icon
                    self.items[index] = .loaded(item)
                }
                objc_sync_exit(self)
            }
            
            self.fetchQueue.addOperation(fetchOp)
            self.fetchQueue.addOperation(iconOp)
        }
    }
    
    func pause() {
        fetchQueue.isSuspended = true
    }
    
    func resume() {
        fetchQueue.isSuspended = false
    }
}

private class StoryFetchOperation: Operation {
    
    private let itemId: ItemId
    
    private(set) var fetchedItem: LoadedItem? = nil
    
    init(with itemId: ItemId) {
        self.itemId = itemId
        super.init()
        self.qualityOfService = .userInitiated
    }
    
    override func main() {
        guard !isCancelled else { return }
        
        let group = DispatchGroup()
        
        group.enter()
        
        API.fetchItem(with: itemId) { result in
            switch result {
            case .failure(let error):
                print("Error Fetching story: \(error.localizedDescription)")
            case .success(let item):
                self.fetchedItem = item
            }
            
            group.leave()
        }
        
        guard !isCancelled else { return }
        
        group.wait()
    }
}

private class IconFetchOperation: Operation {
    
    private(set) var fetchedIcon: UIImage? = nil
    
    override init() {
        super.init()
        self.qualityOfService = .userInitiated
    }
    
    override func main() {
        guard !isCancelled else { return }
        
        guard
            let storyOp = self.dependencies.first as? StoryFetchOperation,
            let item = storyOp.fetchedItem
        else {
            print("No dependency for favicon URL")
            return
        }
        
        guard !isCancelled else { return }
        
        let group = DispatchGroup()
        
        group.enter()
        
        API.fetchFavIcon(for: item) { result in
            switch result {
            case .failure(let error):
                print("Error Fetching Favicon: \(error)")
            case .success(let icon):
                self.fetchedIcon = icon
            }
            
            group.leave()
        }
        
        guard !isCancelled else { return }
        
        group.wait()
    }
}
