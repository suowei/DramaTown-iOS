import UIKit
import Cosmos
import Alamofire
import SwiftyJSON
import TFBubbleItUp
import TagListView

class FavoriteReviewViewController: UIViewController, TagListViewDelegate {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var type: UISegmentedControl!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var tags: TFBubbleItUpView!
    @IBOutlet weak var commonTags: TagListView!
    @IBOutlet weak var reviewTitle: UITextField!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var visible: UISwitch!
    
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
        content.layer.borderColor = UIColor.lightGray.cgColor
        content.layer.borderWidth = 1
        content.layer.cornerRadius = 6
        
        if isUpdate {
            navigationItem.title = "修改收藏与评论"
            if let favorite = favorite {
                type.selectedSegmentIndex = favorite.type
                typeChanged(type)
                rating.rating = favorite.rating
                tags.setStringItems(items: favorite.tags.components(separatedBy: ","))
            }
            navigationItem.rightBarButtonItem?.isEnabled = false
            infoLabel.text = "读取评论"
            infoLabel.isHidden = false
            Alamofire.request(Router.editFavoriteReview(dramaId: favorite!.dramaId)).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let review = Review(json: JSON(value))
                        self.reviewTitle.text = review.title
                        self.content.text = review.content
                        self.visible.isOn = (review.visible == 1)
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.infoLabel.isHidden = true
                    }
                case .failure:
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.infoLabel.isHidden = true
                }
            }
        }
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        let title = reviewTitle.text ?? ""
        let content = self.content.text ?? ""
        if !title.isEmpty && content.isEmpty {
            infoLabel.text = "内容不能为空"
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = false
        favorite!.type = type.selectedSegmentIndex
        favorite!.rating = rating.rating
        favorite!.tags = tags.stringItems().joined(separator: ",")
        infoLabel.text = "处理中……"
        infoLabel.isHidden = false
        let visible = self.visible.isOn ? 1 : 0
        Alamofire.request(Router.getToken()).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let token = Token(json: JSON(value)).token
                    if self.isUpdate {
                        Alamofire.request(Router.updateFavoriteReview(token: token, dramaId: self.favorite!.dramaId, type: self.favorite!.type, rating: self.favorite!.rating, tags: self.favorite!.tags, title: title, content: content, visible: visible)).validate().responseJSON { response in
                            switch response.result {
                            case .success:
                                self.infoLabel.text = "保存成功"
                                self.performSegue(withIdentifier: "UnwindToDramaViewController", sender: nil)
                            case .failure(let error):
                                self.navigationItem.rightBarButtonItem?.isEnabled = true
                                self.infoLabel.text = "保存失败"
                                print(error)
                            }
                        }
                    } else {
                        Alamofire.request(Router.createFavoriteReview(token: token, dramaId: self.favorite!.dramaId, type: self.favorite!.type, rating: self.favorite!.rating, tags: self.favorite!.tags, title: title, content: content, visible: visible)).validate().responseJSON { response in
                            switch response.result {
                            case .success:
                                self.infoLabel.text = "保存成功"
                                self.performSegue(withIdentifier: "UnwindToDramaViewController", sender: nil)
                            case .failure(let error):
                                self.navigationItem.rightBarButtonItem?.isEnabled = true
                                self.infoLabel.text = "保存失败"
                                print(error)
                            }
                        }
                    }
                }
            case .failure(let error):
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.infoLabel.text = "保存失败"
                print(error)
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
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

}
