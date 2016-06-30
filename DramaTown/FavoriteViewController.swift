import UIKit
import Cosmos
import Alamofire
import SwiftyJSON
import TFBubbleItUp
import TagListView

class FavoriteViewController: UIViewController, TagListViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var type: UISegmentedControl!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var tags: TFBubbleItUpView!
    @IBOutlet weak var commonTags: TagListView!
    
    var isUpdate = false
    var favorite: Favorite? = nil
    var userTags: [TagMap]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tags.layer.borderColor = UIColor.lightGrayColor().CGColor
        tags.layer.borderWidth = 1
        tags.layer.cornerRadius = 6
        commonTags.delegate = self
        if let userTags = userTags {
            for tagmap in userTags {
                commonTags.addTag(tagmap.tag!.name)
            }
        }

        if isUpdate {
            titleLabel.text = "修改收藏"
            if let favorite = favorite {
                type.selectedSegmentIndex = favorite.type
                typeChanged(type)
                rating.rating = favorite.rating
                tags.setStringItems(favorite.tags.componentsSeparatedByString(","))
            }
        }
    }
    
    @IBAction func save(sender: UIButton) {
        favorite!.type = type.selectedSegmentIndex
        favorite!.rating = rating.rating
        favorite!.tags = tags.stringItems().joinWithSeparator(",")
        infoLabel.text = "处理中……"
        infoLabel.hidden = false
        Alamofire.request(Router.GetToken()).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let token = Token(json: JSON(value)).token
                    if self.isUpdate {
                        Alamofire.request(Router.UpdateFavorite(token: token, id: self.favorite!.id, type: self.favorite!.type, rating: self.favorite!.rating, tags: self.favorite!.tags)).validate().responseJSON { response in
                                switch response.result {
                                case .Success:
                                    self.performSegueWithIdentifier("UnwindToDramaViewController", sender: nil)
                                case .Failure(let error):
                                    self.infoLabel.text = "保存失败"
                                    print(error)
                                }
                        }
                    } else {
                        Alamofire.request(Router.CreateFavorite(token: token, dramaId: self.favorite!.dramaId, type: self.favorite!.type, rating: self.favorite!.rating, tags: self.favorite!.tags)).validate().responseJSON { response in
                                switch response.result {
                                case .Success:
                                    self.performSegueWithIdentifier("UnwindToDramaViewController", sender: nil)
                                case .Failure(let error):
                                    self.infoLabel.text = "保存失败"
                                    print(error)
                                }
                        }
                    }
                }
            case .Failure(let error):
                self.infoLabel.text = "保存失败"
                print(error)
            }
        }
    }
    
    @IBAction func typeChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            rating.hidden = true
            clearButton.hidden = true
        } else {
            rating.hidden = false
            clearButton.hidden = false
        }
    }
    
    @IBAction func clearRating(sender: UIButton) {
        rating.rating = 0
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        tags.addStringItem(title)
    }
    
    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
