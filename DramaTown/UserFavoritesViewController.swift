import UIKit
import Alamofire
import SwiftyJSON
import MJRefresh

class UserFavoritesViewController: UITableViewController {
    
    var userId: Int?
    var type = 0
    var favorites = [Favorite]()
    
    var currentPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        switch type {
        case 0:
            navigationItem.title = "想听剧集"
        case 1:
            navigationItem.title = "在追剧集"
        case 2:
            navigationItem.title = "听过剧集"
        case 3:
            navigationItem.title = "搁置剧集"
        case 4:
            navigationItem.title = "抛弃剧集"
        default:
            navigationItem.title = "剧集收藏"
        }
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
        tableView.mj_header.beginRefreshing()
    }
    
    func loadNewData() {
        if let userId = userId {
            Alamofire.request(Router.userFavorites(id: userId, type: type, page: 0)).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        self.favorites.removeAll()
                        for favorite in json["data"].arrayValue {
                            self.favorites.append(Favorite(json: favorite))
                        }
                        self.tableView.reloadData()
                        self.currentPage = json["current_page"].intValue
                        if json["next_page_url"] == JSON.null {
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                case .failure(let error):
                    print(error)
                }
                self.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    func loadMoreData() {
        if let userId = userId {
            Alamofire.request(Router.userFavorites(id: userId, type: type, page: currentPage + 1)).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        for favorite in json["data"].arrayValue {
                            self.favorites.append(Favorite(json: favorite))
                        }
                        self.tableView.reloadData()
                        self.currentPage = json["current_page"].intValue
                        if json["next_page_url"] == JSON.null {
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                case .failure(let error):
                    self.tableView.mj_footer.endRefreshing()
                    print(error)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! UserFavoritesTableViewCell
        let favorite = favorites[(indexPath as NSIndexPath).row]
        cell.title.text = favorite.drama?.title
        cell.cv.text = favorite.drama?.cv
        if favorite.rating > 0 {
            cell.rating.rating = favorite.rating
            cell.rating.text = favorite.ratingString
            cell.rating.isHidden = false
        } else {
            cell.rating.isHidden = true
        }
        cell.tags.removeAllTags()
        if !favorite.tags.isEmpty {
            for tag in favorite.tags.components(separatedBy: ",") {
                cell.tags.addTag(tag)
            }
        }
        cell.updatedAt.text = favorite.updatedAt
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDrama" {
            let dramaViewController = segue.destination as! DramaViewController
            if let selectedCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPath(for: selectedCell)!
                dramaViewController.dramaId = favorites[(indexPath as NSIndexPath).row].dramaId
            }
        }
    }

}
