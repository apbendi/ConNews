import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.fetchTopStoriesList { result in
            switch result {
            case .failure(let error):
                print("Error fetching stories: \(error.localizedDescription)")
            case .success(let items):
                let fetcher = ItemsFetcher(items)
                fetcher.start()
            }
        }
    }
}

