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

    @IBAction func save(_ sender: UIButton) {
        epfav!.type = type.selectedSegmentIndex * 2
        epfav!.rating = rating.rating
        infoLabel.text = "处理中……"
        infoLabel.isHidden = false
        Alamofire.request(Router.getToken()).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let token = Token(json: JSON(value)).token
                    if self.isUpdate {
                        Alamofire.request(Router.updateEpfav(token: token, episodeId: self.epfav!.episodeId, type: self.epfav!.type,
                            rating: self.epfav!.rating)).validate().responseJSON { response in
                                switch response.result {
                                case .success:
                                    self.performSegue(withIdentifier: "UnwindToEpisodeViewController", sender: nil)
                                case .failure(let error):
                                    self.infoLabel.text = "保存失败"
                                    print(error)
                                }
                        }
                    } else {
                        Alamofire.request(Router.createEpfav(token: token, episodeId: self.epfav!.episodeId, type: self.epfav!.type,
                            rating: self.epfav!.rating)).validate().responseJSON { response in
                                switch response.result {
                                case .success:
                                    self.performSegue(withIdentifier: "UnwindToEpisodeViewController", sender: nil)
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
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
