import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.fetchTopStoriesList { result in
            switch result {
            case .failure(let error):
                print("Error fetching stories: \(error.localizedDescription)")
            case .success(let items):
                guard let itemId = items.first else {
                    print("No itmes")
                    return
                }
                
                
                API.fetchItem(with: itemId)
            }
        }
    }
}

