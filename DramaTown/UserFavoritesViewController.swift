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
            Alamofire.request(Router.UserFavorites(id: userId, type: type, page: 0)).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        self.favorites.removeAll()
                        for favorite in json["data"].arrayValue {
                            self.favorites.append(Favorite(json: favorite))
                        }
                        self.tableView.reloadData()
                        self.currentPage = json["current_page"].intValue
                        if json["next_page_url"] == nil {
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                case .Failure(let error):
                    print(error)
                }
                self.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    func loadMoreData() {
        if let userId = userId {
            Alamofire.request(Router.UserFavorites(id: userId, type: type, page: currentPage + 1)).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        for favorite in json["data"].arrayValue {
                            self.favorites.append(Favorite(json: favorite))
                        }
                        self.tableView.reloadData()
                        self.currentPage = json["current_page"].intValue
                        if json["next_page_url"] == nil {
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                case .Failure(let error):
                    self.tableView.mj_footer.endRefreshing()
                    print(error)
                }
            }
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteCell", forIndexPath: indexPath) as! UserFavoritesTableViewCell
        let favorite = favorites[indexPath.row]
        cell.title.text = favorite.drama?.title
        cell.cv.text = favorite.drama?.cv
        if favorite.rating > 0 {
            cell.rating.rating = favorite.rating
            cell.rating.text = favorite.ratingString
            cell.rating.hidden = false
        } else {
            cell.rating.hidden = true
        }
        cell.tags.removeAllTags()
        if !favorite.tags.isEmpty {
            for tag in favorite.tags.componentsSeparatedByString(",") {
                cell.tags.addTag(tag)
            }
        }
        cell.updatedAt.text = favorite.updatedAt
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDrama" {
            let dramaViewController = segue.destinationViewController as! DramaViewController
            if let selectedCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCell)!
                dramaViewController.dramaId = favorites[indexPath.row].dramaId
            }
        }
    }

}
