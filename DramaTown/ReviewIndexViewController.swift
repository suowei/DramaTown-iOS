import UIKit
import SwiftyJSON
import MJRefresh
import Alamofire

class ReviewIndexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var reviews = [Review]()
    
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
        tableView.mj_header.beginRefreshing()
    }
    
    func loadNewData() {
        Alamofire.request(Router.ReviewIndex(page: 0)).validate().responseJSON { response in
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
                }
            case .Failure(let error):
                print(error)
            }
            self.tableView.mj_header.endRefreshing()
        }
    }
    
    func loadMoreData() {
        Alamofire.request(Router.ReviewIndex(page: currentPage + 1)).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    for review in json["data"].arrayValue {
                        self.reviews.append(Review(json: review))
                    }
                    self.tableView.reloadData()
                    self.currentPage = json["current_page"].intValue
                }
            case .Failure(let error):
                print(error)
            }
            self.tableView.mj_footer.endRefreshing()
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell", forIndexPath: indexPath) as! ReviewTableViewCell
        let review = reviews[indexPath.row]
        cell.userName.setTitle(review.user!.name, forState: UIControlState.Normal)
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
        cell.userName.tag = indexPath.row
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
        } else if segue.identifier == "ShowUser" {
            let userViewController = segue.destinationViewController as! UserViewController
            if let button = sender as? UIButton {
                userViewController.userId = reviews[button.tag].userId
            }
        }
    }

}

