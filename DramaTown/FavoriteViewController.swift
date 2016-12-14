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
        
        tags.layer.borderColor = UIColor.lightGray.cgColor
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
                tags.setStringItems(items: favorite.tags.components(separatedBy: ","))
            }
        }
    }
    
    @IBAction func save(_ sender: UIButton) {
        favorite!.type = type.selectedSegmentIndex
        favorite!.rating = rating.rating
        favorite!.tags = tags.stringItems().joined(separator: ",")
        infoLabel.text = "处理中……"
        infoLabel.isHidden = false
        Alamofire.request(Router.getToken()).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let token = Token(json: JSON(value)).token
                    if self.isUpdate {
                        Alamofire.request(Router.updateFavorite(token: token, id: self.favorite!.id, type: self.favorite!.type, rating: self.favorite!.rating, tags: self.favorite!.tags)).validate().responseJSON { response in
                                switch response.result {
                                case .success:
                                    self.performSegue(withIdentifier: "UnwindToDramaViewController", sender: nil)
                                case .failure(let error):
                                    self.infoLabel.text = "保存失败"
                                    print(error)
                                }
                        }
                    } else {
                        Alamofire.request(Router.createFavorite(token: token, dramaId: self.favorite!.dramaId, type: self.favorite!.type, rating: self.favorite!.rating, tags: self.favorite!.tags)).validate().responseJSON { response in
                                switch response.result {
                                case .success:
                                    self.performSegue(withIdentifier: "UnwindToDramaViewController", sender: nil)
                                case .failure(let error):
                                    self.infoLabel.text = "保存失败"
                                    print(error)
                                }
                        }
                    }
                }
            case .failure(let error):
                self.infoLabel.text = "保存失败"
                print(error)
            }
        }
    }
    
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            rating.isHidden = true
            clearButton.isHidden = true
        } else {
            rating.isHidden = false
            clearButton.isHidden = false
        }
    }
    
    @IBAction func clearRating(_ sender: UIButton) {
        rating.rating = 0
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        _ = tags.addStringItem(text: title)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
