import UIKit
import SafariServices

class TableViewController: UITableViewController {
    
    fileprivate var fetcher: ItemsFetcher? = nil
    
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
        
        return fetcher.items.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let fetcher = fetcher,
            indexPath.row < fetcher.items.count,
            case .loaded(let item) = fetcher.items[indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell
        else {
            return tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
        }
        
        cell.configure(with: item)
        return cell
    }
}

// MARK: UITableViewDelegate

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let fetcher = fetcher,
            indexPath.row < fetcher.items.count,
            case .loaded = fetcher.items[indexPath.row]
        {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let fetcher = fetcher,
            indexPath.row < fetcher.items.count
        else {
            return
        }
        
        switch fetcher.items[indexPath.row] {
        case .loaded(let item):
            show(url: item.url)
        case .notLoaded(let itemId):
            print("Item Id: \(itemId)")
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
            case .success(let items):
                self.fetcher = ItemsFetcher(items, onUpdate: {
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
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
