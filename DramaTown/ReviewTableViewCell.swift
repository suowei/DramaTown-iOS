import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var dramaTitle: UIButton!
    @IBOutlet weak var episodeTitle: UIButton!
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
