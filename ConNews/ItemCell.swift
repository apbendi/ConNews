import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet fileprivate var titleLabel: UILabel?
    @IBOutlet fileprivate var urlLabel: UILabel?
    @IBOutlet fileprivate var iconImage: UIImageView?
    
    func configure(with item: LoadedItem) {
        titleLabel?.text = item.title
        urlLabel?.text = item.url.host
        
        if let icon = item.icon {
            iconImage?.backgroundColor = UIColor.clear
            iconImage?.image = icon
        }
    }
    
    func notstyle() { print("Style called") }
}
