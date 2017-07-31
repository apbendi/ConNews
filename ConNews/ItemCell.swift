import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet  fileprivate var titleLabel: UILabel?
    
    func configure(with item: LoadedItem) {
        titleLabel?.text = item.title
    }
}
