import UIKit
import Alamofire
import SwiftyJSON
import MJRefresh

class UserEpfavsViewController: UITableViewController {
    
    var userId: Int?
    var type = 0
    var epfavs = [JSON]()
    
    var currentPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch type {
        case 0:
            navigationItem.title = "想听分集"
        case 2:
            navigationItem.title = "听过分集"
        case 4:
            navigationItem.title = "抛弃分集"
        default:
            navigationItem.title = "分集收藏"
        }

        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
        tableView.mj_header.beginRefreshing()
    }
    
    func loadNewData() {
        if let userId = userId {
            Alamofire.request(Router.UserEpfavs(id: userId, type: type, page: 0)).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        self.epfavs = json["data"].arrayValue
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
            Alamofire.request(Router.UserEpfavs(id: userId, type: type, page: currentPage + 1)).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        for epfav in json["data"].arrayValue {
                            self.epfavs.append(epfav)
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
        return epfavs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EpfavCell", forIndexPath: indexPath) as! UserEpfavsTableViewCell
        let epfav = Epfav(json: epfavs[indexPath.row])
        let episode = epfavs[indexPath.row]["episode"]
        cell.title.text = "《\(episode["dramaTitle"].stringValue)》\(episode["title"].stringValue)"
        cell.duration.text = "\(episode["duration"].stringValue)'"
        cell.cv.text = episode["cv"].stringValue
        if epfav.rating > 0 {
            cell.rating.rating = epfav.rating
            cell.rating.text = epfav.ratingString
            cell.rating.hidden = false
        } else {
            cell.rating.hidden = true
        }
        cell.updatedAt.text = epfav.updatedAt
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEpisode" {
            let episodeViewController = segue.destinationViewController as! EpisodeViewController
            if let selectedCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCell)!
                episodeViewController.episodeId = Int(epfavs[indexPath.row]["episode_id"].stringValue)
            }
        }
    }

}
