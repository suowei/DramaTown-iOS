import UIKit
import Cosmos
import Alamofire
import SwiftyJSON

class EpfavViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var type: UISegmentedControl!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var clearButton: UIButton!
    
    var isUpdate = false
    var epfav: Epfav? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isUpdate {
            titleLabel.text = "修改收藏"
            if let epfav = epfav {
                type.selectedSegmentIndex = epfav.type / 2
                typeChanged(type)
                rating.rating = epfav.rating
            }
        }
    }

    @IBAction func save(sender: UIButton) {
        epfav!.type = type.selectedSegmentIndex * 2
        epfav!.rating = rating.rating
        infoLabel.text = "处理中……"
        infoLabel.hidden = false
        Alamofire.request(Router.GetToken()).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let token = Token(json: JSON(value)).token
                    if self.isUpdate {
                        Alamofire.request(Router.UpdateEpfav(token: token, episodeId: self.epfav!.episodeId, type: self.epfav!.type,
                            rating: self.epfav!.rating)).validate().responseJSON { response in
                                switch response.result {
                                case .Success:
                                    self.performSegueWithIdentifier("UnwindToEpisodeViewController", sender: nil)
                                case .Failure(let error):
                                    self.infoLabel.text = "保存失败"
                                    print(error)
                                }
                        }
                    } else {
                        Alamofire.request(Router.CreateEpfav(token: token, episodeId: self.epfav!.episodeId, type: self.epfav!.type,
                            rating: self.epfav!.rating)).validate().responseJSON { response in
                                switch response.result {
                                case .Success:
                                    self.performSegueWithIdentifier("UnwindToEpisodeViewController", sender: nil)
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
    
    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
