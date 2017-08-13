import UIKit
import SafariServices

class TableViewController: UITableViewController {
    
    fileprivate var fetcher: StoriesFetcher? = nil
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadStories()
    }
}

// MARK: UITableViewDataSource

extension TableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetcher = fetcher else {
            return 0
        }
        
        return fetcher.stories.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let fetcher = fetcher,
            indexPath.row < fetcher.stories.count,
            case .loaded(let story) = fetcher.stories[indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath) as? StoryCell
        else {
            return tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
        }
        
        cell.configure(with: story)
        return cell
    }
}

// MARK: UITableViewDelegate

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let fetcher = fetcher,
            indexPath.row < fetcher.stories.count,
            case .loaded = fetcher.stories[indexPath.row]
        {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let fetcher = fetcher,
            indexPath.row < fetcher.stories.count
        else {
            return
        }
        
        switch fetcher.stories[indexPath.row] {
        case .loaded(let story):
            show(url: story.url)
        case .notLoaded(let storyId):
            print("Story Id: \(storyId)")
        }
    }
}

// MARK: SFSafariViewControllerDelegate

extension TableViewController: SFSafariViewControllerDelegate {
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        fetcher?.resume()
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        fetcher?.resume()
    }
}

// MARK: Helpers

private extension TableViewController {
    
    func reloadStories() {
        API.fetchTopStoriesList { result in
            switch result {
            case .failure(let error):
                print("Error fetching stories: \(error.localizedDescription)")
            case .success(let stories):
                self.fetcher = StoriesFetcher(stories, onUpdate: { [weak self] in
                    DispatchQueue.main.async {
                        self?.tableView?.reloadData()
                    }
                })
                
                self.fetcher?.start()
            }
        }
    }
    
    func show(url: URL) {
        let safari = SFSafariViewController(url: url)
        safari.delegate = self
        
        fetcher?.pause()
        
        present(safari, animated: true, completion: nil)
    }
}
