import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet fileprivate var titleLabel: UILabel?
    @IBOutlet fileprivate var urlLabel: UILabel?
    
    func configure(with item: LoadedItem) {
        titleLabel?.text = item.title
        urlLabel?.text = item.url.host
    }
}
