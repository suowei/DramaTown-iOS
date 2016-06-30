import UIKit
import Alamofire
import SwiftyJSON

class WriteReviewViewController: UIViewController {
    
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var reviewTitle: UITextField!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var visible: UISwitch!
    
    var dramaId: Int?
    var episodeId: Int?
    var isUpdate = false
    var id: Int?
    
    var unwindSegueIdentifier = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.layer.borderColor = UIColor.lightGrayColor().CGColor
        content.layer.borderWidth = 1
        content.layer.cornerRadius = 6
    }

    @IBAction func save(sender: UIBarButtonItem) {
        let content = self.content.text ?? ""
        if content.isEmpty {
            info.text = "内容不能为空"
            return
        }
        navigationItem.rightBarButtonItem?.enabled = false
        info.text = "处理中……"
        let title = reviewTitle.text ?? ""
        let visible = self.visible.on ? 1 : 0
        Alamofire.request(Router.GetToken()).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let token = Token(json: JSON(value)).token
                    Alamofire.request(Router.CreateReview(token: token, dramaId: self.dramaId!, episodeId: self.episodeId, title: title, content: content, visible: visible)).validate().responseJSON { response in
                        switch response.result {
                        case .Success:
                            self.info.text = "保存成功"
                            self.performSegueWithIdentifier(self.unwindSegueIdentifier, sender: nil)
                        case .Failure(let error):
                            self.navigationItem.rightBarButtonItem?.enabled = true
                            self.info.text = "保存失败"
                            print(error)
                        }
                    }
                }
            case .Failure(let error):
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.info.text = "保存失败"
                print(error)
            }
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
}
