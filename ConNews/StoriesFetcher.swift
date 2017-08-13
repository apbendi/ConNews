import UIKit

final class StoriesFetcher {
    
    fileprivate(set) var stories: [HNStory] {
        didSet {
            updateCallback()
        }
    }
    
    fileprivate let fetchQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 4
        
        return queue
    }()
    
    fileprivate let serialQueue = DispatchQueue(label: "co.scopelift.ConNews-Serializer", qos: .userInitiated)
    
    fileprivate let updateCallback: () -> Void
    
    init(_ storyIds: [StoryId], onUpdate callback: @escaping () -> Void) {
        stories = storyIds.map({ return HNStory.notLoaded($0) })
        updateCallback = callback
        updateCallback()
    }
    
    func start() {
        for index in 0..<stories.count {
            guard case .notLoaded(let storyId) = stories[index] else {
                return
            }
            
            let fetchOp = StoryFetchOperation(with: storyId)
            fetchOp.completionBlock = {
                guard let story = fetchOp.fetchedStory else {
                    return
                }
                
                print("Fetched Story: \(story)")
                
                self.serialQueue.async {
                    self.stories[index] = .loaded(story)
                }
            }
            
            let iconOp = IconFetchOperation()
            iconOp.addDependency(fetchOp)
            
            iconOp.completionBlock = {
                let icon = iconOp.fetchedIcon ?? #imageLiteral(resourceName: "Placeholder")
                
                print("Fetched Favicon! \(icon)")
                

                if case .loaded(var story) = self.stories[index] {
                    story.icon = icon
                    
                    self.serialQueue.async {
                        self.stories[index] = .loaded(story)
                    }
                }
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
    
    private let storyId: StoryId
    
    private(set) var fetchedStory: LoadedStory? = nil
    
    init(with storyId: StoryId) {
        self.storyId = storyId
        super.init()
        self.qualityOfService = .userInitiated
    }
    
    override func main() {
        guard !isCancelled else { return }
        
        let group = DispatchGroup()
        
        group.enter()
        
        API.fetchStory(with: storyId) { result in
            switch result {
            case .failure(let error):
                print("Error Fetching story: \(error.localizedDescription)")
            case .success(let story):
                self.fetchedStory = story
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
            let story = storyOp.fetchedStory
        else {
            print("No dependency for favicon URL")
            return
        }
        
        guard !isCancelled else { return }
        
        let group = DispatchGroup()
        
        group.enter()
        
        API.fetchFavIcon(for: story) { result in
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
