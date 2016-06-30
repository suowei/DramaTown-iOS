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
    @IBOutlet weak var url: UILabel!
    @IBOutlet weak var sc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let episodeId = episodeId {
            Alamofire.request(Router.ReadEpisode(id: episodeId)).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        self.episode = Episode(json: JSON(value))
                        self.setUpViews()
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }
        
        testLogin()
    }
    
    func testLogin() {
        favoriteType.hidden = true
        ratingBar.hidden = true
        addFavAndReview.hidden = true
        editFavAndReview.hidden = true
        addFavorite.hidden = true
        editFavorite.hidden = true
        deleteFavorite.hidden = true
        
        if NSUserDefaults.standardUserDefaults().valueForKey("UserId") != nil {
            login.hidden = true
            addReview.hidden = false
        } else {
            login.hidden = false
            addReview.hidden = true
        }
    }
    
    func setUpViews() {
        if let episode = episode {
            navigationItem.title = "《\(episode.drama!.title)》\(episode.title)"
            poster.kf_setImageWithURL(NSURL(string: episode.posterUrl)!)
            if episode.userFavorite != nil {
                updateFavorite((episode.userFavorite?.type)!, rating: (episode.userFavorite?.rating)!)
            } else {
                favoriteType.hidden = true
                ratingBar.hidden = true
                addFavAndReview.hidden = false
                editFavAndReview.hidden = true
                addFavorite.hidden = false
                editFavorite.hidden = true
                deleteFavorite.hidden = true
            }
            dramaTitle.setTitle(episode.drama?.title, forState: UIControlState.Normal)
            episodeTitle.text = episode.title
            alias.text = episode.alias
            reviews.setTitle("评论 \(episode.reviews)", forState: UIControlState.Normal)
            type.text = episode.drama?.typeString
            era.text = episode.drama?.eraString
            genre.text = episode.drama?.genre
            original.text = episode.drama?.originalString
            duration.text = "\(episode.duration)分钟"
            releaseDate.text = episode.releaseDate
            url.text = episode.url
            sc.text = "\(episode.sc)\n\(episode.introduction)"
            addReview.enabled = true
            tableView.reloadData()
        }
    }
    
    private func updateFavorite(type: Int, rating: Double) {
        if (episode?.userFavorite == nil) {
            episode?.userFavorite = Epfav(type: type, rating: rating)
        } else {
            episode?.userFavorite?.type = type
            episode?.userFavorite?.rating = rating
        }
        addFavAndReview.hidden = true
        editFavAndReview.hidden = false
        addFavorite.hidden = true
        editFavorite.hidden = false
        deleteFavorite.hidden = false
        favoriteType.text = episode?.userFavorite?.typeString
        favoriteType.hidden = false
        if episode?.userFavorite?.rating != 0 {
            ratingBar.rating = (episode?.userFavorite?.rating)!
            ratingBar.hidden = false
        } else {
            ratingBar.hidden = true
        }
    }

    @IBAction func deleteFavorite(sender: UIButton) {
        let alertController = UIAlertController(title: "删除收藏", message: "确定要删除吗？", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "确定", style: .Default, handler: { _ in
            Alamofire.request(Router.GetToken()).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let token = Token(json: JSON(value)).token
                        Alamofire.request(Router.DestroyEpfav(token: token, episodeId: self.episodeId!)).validate().responseJSON { response in
                                switch response.result {
                                case .Success:
                                    self.episode?.userFavorite = nil
                                    self.favoriteType.hidden = true
                                    self.ratingBar.hidden = true
                                    self.addFavAndReview.hidden = false
                                    self.editFavAndReview.hidden = true
                                    self.addFavorite.hidden = false
                                    self.editFavorite.hidden = true
                                    self.deleteFavorite.hidden = true
                                case .Failure(let error):
                                    print(error)
                                }
                        }
                    }
                case .Failure(let error):
                    print(error)
                }
            }
            })
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowReviews" {
            let episodeReviewsViewController = segue.destinationViewController as! EpisodeReviewsViewController
            episodeReviewsViewController.episodeId = episodeId
        } else if segue.identifier == "ShowDrama" {
            let dramaViewController = segue.destinationViewController as! DramaViewController
            dramaViewController.dramaId = episode?.dramaId
        } else if segue.identifier == "Login" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.unwindSegueIdentifier = "UnwindToEpisodeViewController"
        } else if segue.identifier == "CreateReview" {
            let writeReviewViewController = segue.destinationViewController as! WriteReviewViewController
            writeReviewViewController.unwindSegueIdentifier = "UnwindToEpisodeViewController"
            writeReviewViewController.dramaId = episode?.dramaId
            writeReviewViewController.episodeId = episodeId
        } else if segue.identifier == "CreateEpfav" {
            let epfavViewController = segue.destinationViewController as! EpfavViewController
            epfavViewController.epfav = Epfav(type: 1, rating: 0)
            epfavViewController.epfav?.episodeId = episodeId!
        } else if segue.identifier == "EditEpfav" {
            let epfavViewController = segue.destinationViewController as! EpfavViewController
            let epfav = episode!.userFavorite!
            epfavViewController.epfav = Epfav(type: epfav.type, rating: epfav.rating)
            epfavViewController.epfav?.episodeId = episodeId!
            epfavViewController.isUpdate = true
        } else if segue.identifier == "CreateEpfavReview" {
            let epfavReviewViewController = segue.destinationViewController as! EpfavReviewViewController
            epfavReviewViewController.epfav = Epfav(type: 1, rating: 0)
            epfavReviewViewController.epfav?.episodeId = episodeId!
            epfavReviewViewController.dramaId = episode?.dramaId
        } else if segue.identifier == "EditEpfavReview" {
            let epfavReviewViewController = segue.destinationViewController as! EpfavReviewViewController
            let epfav = episode!.userFavorite!
            epfavReviewViewController.epfav = Epfav(type: epfav.type, rating: epfav.rating)
            epfavReviewViewController.epfav?.episodeId = episodeId!
            epfavReviewViewController.dramaId = episode?.dramaId
            epfavReviewViewController.isUpdate = true
        }
    }
    
    @IBAction func unwindToEpisodeViewController(sender: UIStoryboardSegue) {
        if (sender.sourceViewController as? LoginViewController) != nil {
            testLogin()
        } else if (sender.sourceViewController as? WriteReviewViewController) != nil {
            episode?.reviews += 1
            reviews.setTitle("评论 \(episode!.reviews)", forState: UIControlState.Normal)
        } else if let sourceViewController = sender.sourceViewController as? EpfavViewController, epfav = sourceViewController.epfav {
            updateFavorite(epfav.type, rating: epfav.rating)
        } else if let sourceViewController = sender.sourceViewController as? EpfavReviewViewController, epfav = sourceViewController.epfav {
            updateFavorite(epfav.type, rating: epfav.rating)
        }
    }
    
}
