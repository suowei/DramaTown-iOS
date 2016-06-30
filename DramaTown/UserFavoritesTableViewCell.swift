import UIKit
import Cosmos
import TagListView

class UserFavoritesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cv: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var tags: TagListView!
    @IBOutlet weak var updatedAt: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
