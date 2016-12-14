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
        content.layer.borderColor = UIColor.lightGray.cgColor
        content.layer.borderWidth = 1
        content.layer.cornerRadius = 6

        if isUpdate {
            navigationItem.title = "修改收藏与评论"
            if let epfav = epfav {
                type.selectedSegmentIndex = epfav.type / 2
                typeChanged(type)
                rating.rating = epfav.rating
            }
            navigationItem.rightBarButtonItem?.isEnabled = false
            infoLabel.text = "读取评论"
            infoLabel.isHidden = false
            Alamofire.request(Router.editEpfavReview(episodeId: epfav!.episodeId)).validate().responseJSON { response in
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
        epfav!.type = type.selectedSegmentIndex * 2
        epfav!.rating = rating.rating
        infoLabel.text = "处理中……"
        infoLabel.isHidden = false
        let visible = self.visible.isOn ? 1 : 0
        Alamofire.request(Router.getToken()).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let token = Token(json: JSON(value)).token
                    if self.isUpdate {
                        Alamofire.request(Router.updateEpfavReview(token: token, episodeId: self.epfav!.episodeId, dramaId: self.dramaId!, type: self.epfav!.type, rating: self.epfav!.rating, title: title, content: content, visible: visible)).validate().responseJSON { response in
                                switch response.result {
                                case .success:
                                    self.infoLabel.text = "保存成功"
                                    self.performSegue(withIdentifier: "UnwindToEpisodeViewController", sender: nil)
                                case .failure(let error):
                                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                                    self.infoLabel.text = "保存失败"
                                    print(error)
                                }
                        }
                    } else {
                        Alamofire.request(Router.createEpfavReview(token: token, episodeId: self.epfav!.episodeId, dramaId: self.dramaId!, type: self.epfav!.type, rating: self.epfav!.rating, title: title, content: content, visible: visible)).validate().responseJSON { response in
                                switch response.result {
                                case .success:
                                    self.infoLabel.text = "保存成功"
                                    self.performSegue(withIdentifier: "UnwindToEpisodeViewController", sender: nil)
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

}
