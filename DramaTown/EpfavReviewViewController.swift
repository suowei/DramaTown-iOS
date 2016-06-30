import UIKit
import Cosmos
import Alamofire
import SwiftyJSON

class EpfavReviewViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var type: UISegmentedControl!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var reviewTitle: UITextField!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var visible: UISwitch!
    
    var dramaId: Int?
    var isUpdate = false
    var epfav: Epfav? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        content.layer.borderColor = UIColor.lightGrayColor().CGColor
        content.layer.borderWidth = 1
        content.layer.cornerRadius = 6

        if isUpdate {
            navigationItem.title = "修改收藏与评论"
            if let epfav = epfav {
                type.selectedSegmentIndex = epfav.type / 2
                typeChanged(type)
                rating.rating = epfav.rating
            }
            navigationItem.rightBarButtonItem?.enabled = false
            infoLabel.text = "读取评论"
            infoLabel.hidden = false
            Alamofire.request(Router.EditEpfavReview(episodeId: epfav!.episodeId)).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let review = Review(json: JSON(value))
                        self.reviewTitle.text = review.title
                        self.content.text = review.content
                        self.visible.on = (review.visible == 1)
                        self.navigationItem.rightBarButtonItem?.enabled = true
                        self.infoLabel.hidden = true
                    }
                case .Failure:
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    self.infoLabel.hidden = true
                }
            }
        }
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        let title = reviewTitle.text ?? ""
        let content = self.content.text ?? ""
        if !title.isEmpty && content.isEmpty {
            infoLabel.text = "内容不能为空"
            return
        }
        navigationItem.rightBarButtonItem?.enabled = false
        epfav!.type = type.selectedSegmentIndex * 2
        epfav!.rating = rating.rating
        infoLabel.text = "处理中……"
        infoLabel.hidden = false
        let visible = self.visible.on ? 1 : 0
        Alamofire.request(Router.GetToken()).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let token = Token(json: JSON(value)).token
                    if self.isUpdate {
                        Alamofire.request(Router.UpdateEpfavReview(token: token, episodeId: self.epfav!.episodeId, dramaId: self.dramaId!, type: self.epfav!.type, rating: self.epfav!.rating, title: title, content: content, visible: visible)).validate().responseJSON { response in
                                switch response.result {
                                case .Success:
                                    self.infoLabel.text = "保存成功"
                                    self.performSegueWithIdentifier("UnwindToEpisodeViewController", sender: nil)
                                case .Failure(let error):
                                    self.navigationItem.rightBarButtonItem?.enabled = true
                                    self.infoLabel.text = "保存失败"
                                    print(error)
                                }
                        }
                    } else {
                        Alamofire.request(Router.CreateEpfavReview(token: token, episodeId: self.epfav!.episodeId, dramaId: self.dramaId!, type: self.epfav!.type, rating: self.epfav!.rating, title: title, content: content, visible: visible)).validate().responseJSON { response in
                                switch response.result {
                                case .Success:
                                    self.infoLabel.text = "保存成功"
                                    self.performSegueWithIdentifier("UnwindToEpisodeViewController", sender: nil)
                                case .Failure(let error):
                                    self.navigationItem.rightBarButtonItem?.enabled = true
                                    self.infoLabel.text = "保存失败"
                                    print(error)
                                }
                        }
                    }
                }
            case .Failure(let error):
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.infoLabel.text = "保存失败"
                print(error)
            }
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
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

}
