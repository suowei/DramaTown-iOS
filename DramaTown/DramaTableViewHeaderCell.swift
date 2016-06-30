import UIKit
import Cosmos
import TagListView

class DramaTableViewHeaderCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var era: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var original: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var cv: UILabel!
    @IBOutlet weak var introduction: UILabel!
    @IBOutlet weak var tags: UILabel!
    @IBOutlet weak var favoriteType: UILabel!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var userTagsLabel: UILabel!
    @IBOutlet weak var userTags: TagListView!
    @IBOutlet weak var reviews: UIButton!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var addFavAndReview: UIButton!
    @IBOutlet weak var editFavAndReview: UIButton!
    @IBOutlet weak var addFav: UIButton!
    @IBOutlet weak var editFav: UIButton!
    @IBOutlet weak var deleteFav: UIButton!
    @IBOutlet weak var addReview: UIButton!
}
