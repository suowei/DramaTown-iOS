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
            Alamofire.request(Router.readDrama(id: dramaId)).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        self.drama = Drama(json: JSON(value))
                        self.navigationItem.title = self.drama!.title
                        self.testLogin()
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func testLogin() {
        let panel = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DramaTableViewHeaderCell
        panel.favoriteType.isHidden = true
        panel.ratingBar.isHidden = true
        panel.userTags.isHidden = true
        panel.userTagsLabel.isHidden = true
        panel.addFavAndReview.isHidden = true
        panel.editFavAndReview.isHidden = true
        panel.addFav.isHidden = true
        panel.editFav.isHidden = true
        panel.deleteFav.isHidden = true
        if UserDefaults.standard.value(forKey: "UserId") != nil {
            panel.login.isHidden = true
            panel.addReview.isHidden = false
        } else {
            panel.login.isHidden = false
            panel.addReview.isHidden = true
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! DramaTableViewHeaderCell
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
                cell.reviews.setTitle("评论 \(drama.reviews)", for: UIControlState())
                cell.addReview.isEnabled = true
                if drama.userFavorite != nil {
                    updateFavorite(cell, type: (drama.userFavorite?.type)!, rating: (drama.userFavorite?.rating)!, tags: (drama.userFavorite?.tags)!)
                } else {
                    cell.favoriteType.isHidden = true
                    cell.ratingBar.isHidden = true
                    cell.userTags.isHidden = true
                    cell.userTagsLabel.isHidden = true
                    cell.addFavAndReview.isHidden = false
                    cell.editFavAndReview.isHidden = true
                    cell.addFav.isHidden = false
                    cell.editFav.isHidden = true
                    cell.deleteFav.isHidden = true
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as! DramaTableViewEpisodeCell
            if let episode = drama?.episodes![(indexPath as NSIndexPath).row] {
                cell.poster.kf.setImage(with: URL(string: episode.posterUrl)!)
                cell.title.text = "\(episode.title) \(episode.alias)"
                cell.releaseDate.text = episode.releaseDate
            }
            return cell
        }
    }
    
    fileprivate func updateFavorite(_ cell: DramaTableViewHeaderCell, type: Int, rating: Double, tags: String) {
        if (drama?.userFavorite == nil) {
            drama?.userFavorite = Favorite(type: type, rating: rating, tags: tags)
        } else {
            drama?.userFavorite?.type = type
            drama?.userFavorite?.rating = rating
            drama?.userFavorite?.tags = tags
        }
        cell.addFavAndReview.isHidden = true
        cell.editFavAndReview.isHidden = false
        cell.addFav.isHidden = true
        cell.editFav.isHidden = false
        cell.deleteFav.isHidden = false
        cell.favoriteType.text = drama?.userFavorite?.typeString
        cell.favoriteType.isHidden = false
        if drama?.userFavorite?.rating != 0 {
            cell.ratingBar.rating = (drama?.userFavorite?.rating)!
            cell.ratingBar.isHidden = false
        } else {
            cell.ratingBar.isHidden = true
        }
        let userTags = drama?.userFavorite?.tags
        if userTags != nil && !(userTags!.isEmpty) {
            for tag in userTags!.components(separatedBy: ",") {
                cell.userTags.addTag(tag)
            }
            cell.userTags.isHidden = false
            cell.userTagsLabel.isHidden = false
        } else {
            cell.userTags.isHidden = true
            cell.userTagsLabel.isHidden = true
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
                        Alamofire.request(Router.destroyFavorite(token: token, id: self.drama!.userFavorite!.id)).validate().responseJSON { response in
                            switch response.result {
                            case .success:
                                self.drama?.userFavorite = nil
                                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DramaTableViewHeaderCell
                                cell.favoriteType.isHidden = true
                                cell.ratingBar.isHidden = true
                                cell.userTags.isHidden = true
                                cell.userTagsLabel.isHidden = true
                                cell.addFavAndReview.isHidden = false
                                cell.editFavAndReview.isHidden = true
                                cell.addFav.isHidden = false
                                cell.editFav.isHidden = true
                                cell.deleteFav.isHidden = true
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowReviews" {
            let dramaReviewsViewController = segue.destination as! DramaReviewsViewController
            dramaReviewsViewController.dramaId = dramaId
        } else if segue.identifier == "ShowEpisode" {
            let episodeViewController = segue.destination as! EpisodeViewController
            if let selectedCell = sender as? DramaTableViewEpisodeCell {
                let indexPath = tableView.indexPath(for: selectedCell)!
                let selectedEpisode = drama?.episodes![(indexPath as NSIndexPath).row]
                episodeViewController.episodeId = selectedEpisode?.id
            }
        } else if segue.identifier == "Login" {
            let loginViewController = segue.destination as! LoginViewController
            loginViewController.unwindSegueIdentifier = "UnwindToDramaViewController"
        } else if segue.identifier == "CreateReview" {
            let writeReviewViewController = segue.destination as! WriteReviewViewController
            writeReviewViewController.unwindSegueIdentifier = "UnwindToDramaViewController"
            writeReviewViewController.dramaId = dramaId
        } else if segue.identifier == "CreateFavorite" {
            let favoriteViewController = segue.destination as! FavoriteViewController
            favoriteViewController.favorite = Favorite(type: 1, rating: 0, tags: "")
            favoriteViewController.favorite?.dramaId = dramaId!
            favoriteViewController.userTags = drama?.userTags
        } else if segue.identifier == "EditFavorite" {
            let favoriteViewController = segue.destination as! FavoriteViewController
            let favorite = drama!.userFavorite!
            favoriteViewController.favorite = Favorite(type: favorite.type, rating: favorite.rating, tags: favorite.tags)
            favoriteViewController.favorite?.id = favorite.id
            favoriteViewController.userTags = drama?.userTags
            favoriteViewController.isUpdate = true
        } else if segue.identifier == "CreateFavoriteReview" {
            let favoriteReviewViewController = segue.destination as! FavoriteReviewViewController
            favoriteReviewViewController.favorite = Favorite(type: 1, rating: 0, tags: "")
            favoriteReviewViewController.favorite?.dramaId = dramaId!
            favoriteReviewViewController.userTags = drama?.userTags
        } else if segue.identifier == "EditFavoriteReview" {
            let favoriteReviewViewController = segue.destination as! FavoriteReviewViewController
            let favorite = drama!.userFavorite!
            favoriteReviewViewController.favorite = Favorite(type: favorite.type, rating: favorite.rating, tags: favorite.tags)
            favoriteReviewViewController.favorite?.id = favorite.id
            favoriteReviewViewController.favorite?.dramaId = dramaId!
            favoriteReviewViewController.userTags = drama?.userTags
            favoriteReviewViewController.isUpdate = true
        }
    }
    
    @IBAction func unwindToDramaViewController(_ sender: UIStoryboardSegue) {
        if (sender.source as? LoginViewController) != nil {
            testLogin()
        } else if (sender.source as? WriteReviewViewController) != nil {
            drama?.reviews += 1
            let panel = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DramaTableViewHeaderCell
            panel.reviews.setTitle("评论 \(drama!.reviews)", for: UIControlState())
        } else if let sourceViewController = sender.source as? FavoriteViewController, let favorite = sourceViewController.favorite {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DramaTableViewHeaderCell
            updateFavorite(cell, type: favorite.type, rating: favorite.rating, tags: favorite.tags)
        } else if let sourceViewController = sender.source as? FavoriteReviewViewController, let favorite = sourceViewController.favorite {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DramaTableViewHeaderCell
            updateFavorite(cell, type: favorite.type, rating: favorite.rating, tags: favorite.tags)
        }
    }
    
}
