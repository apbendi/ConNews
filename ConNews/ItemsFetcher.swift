import Foundation

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
            
            self.fetchQueue.addOperation(fetchOp)
        }
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
        
        guard !isCancelled else { return }
    }
}
