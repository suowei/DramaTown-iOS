import UIKit
import SwiftyJSON
import MJRefresh
import Alamofire

class EpisodeReviewsViewController: UITableViewController {

    var episodeId: Int?
    var reviews = [Review]()
    
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
        tableView.mj_header.beginRefreshing()
    }
    
    func loadNewData() {
        if let episodeId = episodeId {
            Alamofire.request(Router.EpisodeReviews(id: episodeId, page: 0)).validate().responseJSON { response in
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
        if let episodeId = episodeId {
            Alamofire.request(Router.EpisodeReviews(id: episodeId, page: currentPage + 1)).validate().responseJSON { response in
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell", forIndexPath: indexPath) as! ReviewTableViewCell
        let review = reviews[indexPath.row]
        cell.userName.setTitle(review.user!.name, forState: UIControlState.Normal)
        cell.createdAt.text = review.createdAt
        cell.title.text = review.title
        cell.content.text = review.content
        cell.userName.tag = indexPath.row
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowUser" {
            let userViewController = segue.destinationViewController as! UserViewController
            if let button = sender as? UIButton {
                userViewController.userId = reviews[button.tag].userId
            }
        }
    }

}
