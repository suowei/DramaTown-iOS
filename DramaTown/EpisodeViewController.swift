import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import Cosmos

class EpisodeViewController: UITableViewController {
    
    var episodeId: Int?
    var episode: Episode? = nil

    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var dramaTitle: UIButton!
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var alias: UILabel!
    @IBOutlet weak var favoriteType: UILabel!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var reviews: UIButton!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var addFavAndReview: UIButton!
    @IBOutlet weak var editFavAndReview: UIButton!
    @IBOutlet weak var addFavorite: UIButton!
    @IBOutlet weak var deleteFavorite: UIButton!
    @IBOutlet weak var editFavorite: UIButton!
    @IBOutlet weak var addReview: UIButton!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var era: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var original: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var url: UITextView!
    @IBOutlet weak var sc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        url.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        if let episodeId = episodeId {
            Alamofire.request(Router.readEpisode(id: episodeId)).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        self.episode = Episode(json: JSON(value))
                        self.setUpViews()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        testLogin()
    }
    
    func testLogin() {
        favoriteType.isHidden = true
        ratingBar.isHidden = true
        addFavAndReview.isHidden = true
        editFavAndReview.isHidden = true
        addFavorite.isHidden = true
        editFavorite.isHidden = true
        deleteFavorite.isHidden = true
        
        if UserDefaults.standard.value(forKey: "UserId") != nil {
            login.isHidden = true
            addReview.isHidden = false
        } else {
            login.isHidden = false
            addReview.isHidden = true
        }
    }
    
    func setUpViews() {
        if let episode = episode {
            navigationItem.title = "《\(episode.drama!.title)》\(episode.title)"
            poster.kf.setImage(with: URL(string: episode.posterUrl)!)
            if episode.userFavorite != nil {
                updateFavorite((episode.userFavorite?.type)!, rating: (episode.userFavorite?.rating)!)
            } else {
                favoriteType.isHidden = true
                ratingBar.isHidden = true
                addFavAndReview.isHidden = false
                editFavAndReview.isHidden = true
                addFavorite.isHidden = false
                editFavorite.isHidden = true
                deleteFavorite.isHidden = true
            }
            dramaTitle.setTitle(episode.drama?.title, for: UIControlState())
            episodeTitle.text = episode.title
            alias.text = episode.alias
            reviews.setTitle("评论 \(episode.reviews)", for: UIControlState())
            type.text = episode.drama?.typeString
            era.text = episode.drama?.eraString
            genre.text = episode.drama?.genre
            original.text = episode.drama?.originalString
            duration.text = "\(episode.duration)分钟"
            releaseDate.text = episode.releaseDate
            url.text = episode.url
            sc.text = "\(episode.sc)\n\(episode.introduction)"
            addReview.isEnabled = true
            tableView.reloadData()
        }
    }
    
    fileprivate func updateFavorite(_ type: Int, rating: Double) {
        if (episode?.userFavorite == nil) {
            episode?.userFavorite = Epfav(type: type, rating: rating)
        } else {
            episode?.userFavorite?.type = type
            episode?.userFavorite?.rating = rating
        }
        addFavAndReview.isHidden = true
        editFavAndReview.isHidden = false
        addFavorite.isHidden = true
        editFavorite.isHidden = false
        deleteFavorite.isHidden = false
        favoriteType.text = episode?.userFavorite?.typeString
        favoriteType.isHidden = false
        if episode?.userFavorite?.rating != 0 {
            ratingBar.rating = (episode?.userFavorite?.rating)!
            ratingBar.isHidden = false
        } else {
            ratingBar.isHidden = true
        }
    }

    @IBAction func deleteFavorite(_ sender: UIButton) {
        let alertController = UIAlertController(title: "删除收藏", message: "确定要删除吗？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: { _ in
            Alamofire.request(Router.getToken()).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let token = Token(json: JSON(value)).token
                        Alamofire.request(Router.destroyEpfav(token: token, episodeId: self.episodeId!)).validate().responseJSON { response in
                                switch response.result {
                                case .success:
                                    self.episode?.userFavorite = nil
                                    self.favoriteType.isHidden = true
                                    self.ratingBar.isHidden = true
                                    self.addFavAndReview.isHidden = false
                                    self.editFavAndReview.isHidden = true
                                    self.addFavorite.isHidden = false
                                    self.editFavorite.isHidden = true
                                    self.deleteFavorite.isHidden = true
                                case .failure(let error):
                                    print(error)
                                }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
            })
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowReviews" {
            let episodeReviewsViewController = segue.destination as! EpisodeReviewsViewController
            episodeReviewsViewController.episodeId = episodeId
        } else if segue.identifier == "ShowDrama" {
            let dramaViewController = segue.destination as! DramaViewController
            dramaViewController.dramaId = episode?.dramaId
        } else if segue.identifier == "Login" {
            let loginViewController = segue.destination as! LoginViewController
            loginViewController.unwindSegueIdentifier = "UnwindToEpisodeViewController"
        } else if segue.identifier == "CreateReview" {
            let writeReviewViewController = segue.destination as! WriteReviewViewController
            writeReviewViewController.unwindSegueIdentifier = "UnwindToEpisodeViewController"
            writeReviewViewController.dramaId = episode?.dramaId
            writeReviewViewController.episodeId = episodeId
        } else if segue.identifier == "CreateEpfav" {
            let epfavViewController = segue.destination as! EpfavViewController
            epfavViewController.epfav = Epfav(type: 1, rating: 0)
            epfavViewController.epfav?.episodeId = episodeId!
        } else if segue.identifier == "EditEpfav" {
            let epfavViewController = segue.destination as! EpfavViewController
            let epfav = episode!.userFavorite!
            epfavViewController.epfav = Epfav(type: epfav.type, rating: epfav.rating)
            epfavViewController.epfav?.episodeId = episodeId!
            epfavViewController.isUpdate = true
        } else if segue.identifier == "CreateEpfavReview" {
            let epfavReviewViewController = segue.destination as! EpfavReviewViewController
            epfavReviewViewController.epfav = Epfav(type: 1, rating: 0)
            epfavReviewViewController.epfav?.episodeId = episodeId!
            epfavReviewViewController.dramaId = episode?.dramaId
        } else if segue.identifier == "EditEpfavReview" {
            let epfavReviewViewController = segue.destination as! EpfavReviewViewController
            let epfav = episode!.userFavorite!
            epfavReviewViewController.epfav = Epfav(type: epfav.type, rating: epfav.rating)
            epfavReviewViewController.epfav?.episodeId = episodeId!
            epfavReviewViewController.dramaId = episode?.dramaId
            epfavReviewViewController.isUpdate = true
        }
    }
    
    @IBAction func unwindToEpisodeViewController(_ sender: UIStoryboardSegue) {
        if (sender.source as? LoginViewController) != nil {
            testLogin()
        } else if (sender.source as? WriteReviewViewController) != nil {
            episode?.reviews += 1
            reviews.setTitle("评论 \(episode!.reviews)", for: UIControlState())
        } else if let sourceViewController = sender.source as? EpfavViewController, let epfav = sourceViewController.epfav {
            updateFavorite(epfav.type, rating: epfav.rating)
        } else if let sourceViewController = sender.source as? EpfavReviewViewController, let epfav = sourceViewController.epfav {
            updateFavorite(epfav.type, rating: epfav.rating)
        }
    }
    
}
