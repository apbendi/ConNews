import UIKit

class StoryCell: UITableViewCell {
    
    @IBOutlet fileprivate var titleLabel: UILabel?
    @IBOutlet fileprivate var urlLabel: UILabel?
    @IBOutlet fileprivate var iconImage: UIImageView?
    
    func configure(with story: LoadedStory) {
        titleLabel?.text = story.title
        urlLabel?.text = story.url.host
        
        if let icon = story.icon {
            iconImage?.backgroundColor = UIColor.clear
            iconImage?.image = icon
        }
    }
}
