import UIKit

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let fetcher = fetcher,
            indexPath.row < fetcher.items.count
        else {
            return
        }
        
        switch fetcher.items[indexPath.row] {
        case .loaded:
            break
        case .notLoaded(let itemId):
            print("Item Id: \(itemId)")
        }
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
}
