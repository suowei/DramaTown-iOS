import UIKit
import Alamofire
import SwiftyJSON
import MJRefresh

class UserReviewsViewController: UITableViewController {
    
    var userId: Int?
    var reviews = [Review]()
    
    var currentPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
        tableView.mj_header.beginRefreshing()
    }
    
    func loadNewData() {
        if let userId = userId {
            Alamofire.request(Router.UserReviews(id: userId, page: 0)).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        self.reviews.removeAll()
                        for review in json["data"].arrayValue {
                            self.reviews.append(Review(json: review))
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
            Alamofire.request(Router.UserReviews(id: userId, page: currentPage + 1)).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        for review in json["data"].arrayValue {
                            self.reviews.append(Review(json: review))
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
        return reviews.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell", forIndexPath: indexPath) as! ReviewTableViewCell
        let review = reviews[indexPath.row]
        cell.dramaTitle.setTitle(review.drama!.title, forState: UIControlState.Normal)
        if let episode = review.episode {
            cell.episodeTitle.setTitle(episode.title, forState: UIControlState.Normal)
            cell.episodeTitle.hidden = false
        } else {
            cell.episodeTitle.setTitle("", forState: UIControlState.Normal)
            cell.episodeTitle.hidden = true
        }
        cell.createdAt.text = review.createdAt
        cell.title.text = review.title
        cell.content.text = review.content
        cell.dramaTitle.tag = indexPath.row
        cell.episodeTitle.tag = indexPath.row
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDrama" {
            let dramaViewController = segue.destinationViewController as! DramaViewController
            if let button = sender as? UIButton {
                dramaViewController.dramaId = reviews[button.tag].dramaId
            }
        } else if segue.identifier == "ShowEpisode" {
            let episodeViewController = segue.destinationViewController as! EpisodeViewController
            if let button = sender as? UIButton {
                episodeViewController.episodeId = reviews[button.tag].episodeId
            }
        }
    }

}