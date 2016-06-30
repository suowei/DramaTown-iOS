import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class DramaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dramaId: Int?
    var drama: Drama? = nil

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if let dramaId = dramaId {
            Alamofire.request(Router.ReadDrama(id: dramaId)).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        self.drama = Drama(json: JSON(value))
                        self.navigationItem.title = self.drama!.title
                        self.testLogin()
                        self.tableView.reloadData()
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func testLogin() {
        let panel = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DramaTableViewHeaderCell
        panel.favoriteType.hidden = true
        panel.ratingBar.hidden = true
        panel.userTags.hidden = true
        panel.userTagsLabel.hidden = true
        panel.addFavAndReview.hidden = true
        panel.editFavAndReview.hidden = true
        panel.addFav.hidden = true
        panel.editFav.hidden = true
        panel.deleteFav.hidden = true
        if NSUserDefaults.standardUserDefaults().valueForKey("UserId") != nil {
            panel.login.hidden = true
            panel.addReview.hidden = false
        } else {
            panel.login.hidden = false
            panel.addReview.hidden = true
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let episodes = drama?.episodes {
                return episodes.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell", forIndexPath: indexPath) as! DramaTableViewHeaderCell
            if let drama = drama {
                cell.title.text = drama.title
                cell.type.text = drama.typeString
                cell.era.text = drama.eraString
                cell.genre.text = drama.genre
                cell.original.text = drama.originalString
                cell.count.text = String(drama.count)
                cell.state.text = drama.stateString
                cell.cv.text = drama.cv
                cell.introduction.text = drama.introduction
                var commtags = ""
                if drama.commtags != nil {
                    for tagmap in drama.commtags! {
                        commtags += "\(tagmap.tag!.name)(\(tagmap.count)) "
                    }
                }
                cell.tags.text = commtags
                cell.reviews.setTitle("评论 \(drama.reviews)", forState: UIControlState.Normal)
                cell.addReview.enabled = true
                if drama.userFavorite != nil {
                    updateFavorite(cell, type: (drama.userFavorite?.type)!, rating: (drama.userFavorite?.rating)!, tags: (drama.userFavorite?.tags)!)
                } else {
                    cell.favoriteType.hidden = true
                    cell.ratingBar.hidden = true
                    cell.userTags.hidden = true
                    cell.userTagsLabel.hidden = true
                    cell.addFavAndReview.hidden = false
                    cell.editFavAndReview.hidden = true
                    cell.addFav.hidden = false
                    cell.editFav.hidden = true
                    cell.deleteFav.hidden = true
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("EpisodeCell", forIndexPath: indexPath) as! DramaTableViewEpisodeCell
            if let episode = drama?.episodes![indexPath.row] {
                cell.poster.kf_setImageWithURL(NSURL(string: episode.posterUrl)!)
                cell.title.text = "\(episode.title) \(episode.alias)"
                cell.releaseDate.text = episode.releaseDate
            }
            return cell
        }
    }
    
    private func updateFavorite(cell: DramaTableViewHeaderCell, type: Int, rating: Double, tags: String) {
        if (drama?.userFavorite == nil) {
            drama?.userFavorite = Favorite(type: type, rating: rating, tags: tags)
        } else {
            drama?.userFavorite?.type = type
            drama?.userFavorite?.rating = rating
            drama?.userFavorite?.tags = tags
        }
        cell.addFavAndReview.hidden = true
        cell.editFavAndReview.hidden = false
        cell.addFav.hidden = true
        cell.editFav.hidden = false
        cell.deleteFav.hidden = false
        cell.favoriteType.text = drama?.userFavorite?.typeString
        cell.favoriteType.hidden = false
        if drama?.userFavorite?.rating != 0 {
            cell.ratingBar.rating = (drama?.userFavorite?.rating)!
            cell.ratingBar.hidden = false
        } else {
            cell.ratingBar.hidden = true
        }
        let userTags = drama?.userFavorite?.tags
        if userTags != nil && !(userTags!.isEmpty) {
            for tag in userTags!.componentsSeparatedByString(",") {
                cell.userTags.addTag(tag)
            }
            cell.userTags.hidden = false
            cell.userTagsLabel.hidden = false
        } else {
            cell.userTags.hidden = true
            cell.userTagsLabel.hidden = true
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
                        Alamofire.request(Router.DestroyFavorite(token: token, id: self.drama!.userFavorite!.id)).validate().responseJSON { response in
                            switch response.result {
                            case .Success:
                                self.drama?.userFavorite = nil
                                let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DramaTableViewHeaderCell
                                cell.favoriteType.hidden = true
                                cell.ratingBar.hidden = true
                                cell.userTags.hidden = true
                                cell.userTagsLabel.hidden = true
                                cell.addFavAndReview.hidden = false
                                cell.editFavAndReview.hidden = true
                                cell.addFav.hidden = false
                                cell.editFav.hidden = true
                                cell.deleteFav.hidden = true
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowReviews" {
            let dramaReviewsViewController = segue.destinationViewController as! DramaReviewsViewController
            dramaReviewsViewController.dramaId = dramaId
        } else if segue.identifier == "ShowEpisode" {
            let episodeViewController = segue.destinationViewController as! EpisodeViewController
            if let selectedCell = sender as? DramaTableViewEpisodeCell {
                let indexPath = tableView.indexPathForCell(selectedCell)!
                let selectedEpisode = drama?.episodes![indexPath.row]
                episodeViewController.episodeId = selectedEpisode?.id
            }
        } else if segue.identifier == "Login" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.unwindSegueIdentifier = "UnwindToDramaViewController"
        } else if segue.identifier == "CreateReview" {
            let writeReviewViewController = segue.destinationViewController as! WriteReviewViewController
            writeReviewViewController.unwindSegueIdentifier = "UnwindToDramaViewController"
            writeReviewViewController.dramaId = dramaId
        } else if segue.identifier == "CreateFavorite" {
            let favoriteViewController = segue.destinationViewController as! FavoriteViewController
            favoriteViewController.favorite = Favorite(type: 1, rating: 0, tags: "")
            favoriteViewController.favorite?.dramaId = dramaId!
            favoriteViewController.userTags = drama?.userTags
        } else if segue.identifier == "EditFavorite" {
            let favoriteViewController = segue.destinationViewController as! FavoriteViewController
            let favorite = drama!.userFavorite!
            favoriteViewController.favorite = Favorite(type: favorite.type, rating: favorite.rating, tags: favorite.tags)
            favoriteViewController.favorite?.id = favorite.id
            favoriteViewController.userTags = drama?.userTags
            favoriteViewController.isUpdate = true
        } else if segue.identifier == "CreateFavoriteReview" {
            let favoriteReviewViewController = segue.destinationViewController as! FavoriteReviewViewController
            favoriteReviewViewController.favorite = Favorite(type: 1, rating: 0, tags: "")
            favoriteReviewViewController.favorite?.dramaId = dramaId!
            favoriteReviewViewController.userTags = drama?.userTags
        } else if segue.identifier == "EditFavoriteReview" {
            let favoriteReviewViewController = segue.destinationViewController as! FavoriteReviewViewController
            let favorite = drama!.userFavorite!
            favoriteReviewViewController.favorite = Favorite(type: favorite.type, rating: favorite.rating, tags: favorite.tags)
            favoriteReviewViewController.favorite?.id = favorite.id
            favoriteReviewViewController.favorite?.dramaId = dramaId!
            favoriteReviewViewController.userTags = drama?.userTags
            favoriteReviewViewController.isUpdate = true
        }
    }
    
    @IBAction func unwindToDramaViewController(sender: UIStoryboardSegue) {
        if (sender.sourceViewController as? LoginViewController) != nil {
            testLogin()
        } else if (sender.sourceViewController as? WriteReviewViewController) != nil {
            drama?.reviews += 1
            let panel = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DramaTableViewHeaderCell
            panel.reviews.setTitle("评论 \(drama!.reviews)", forState: UIControlState.Normal)
        } else if let sourceViewController = sender.sourceViewController as? FavoriteViewController, favorite = sourceViewController.favorite {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DramaTableViewHeaderCell
            updateFavorite(cell, type: favorite.type, rating: favorite.rating, tags: favorite.tags)
        } else if let sourceViewController = sender.sourceViewController as? FavoriteReviewViewController, favorite = sourceViewController.favorite {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DramaTableViewHeaderCell
            updateFavorite(cell, type: favorite.type, rating: favorite.rating, tags: favorite.tags)
        }
    }
    
}
