import UIKit
import Alamofire
import MJRefresh
import SwiftyJSON

class DramaReviewsViewController: UITableViewController {

    var dramaId: Int?
    var reviews = [Review]()
    
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
        tableView.mj_header.beginRefreshing()
    }
    
    func loadNewData() {
        if let dramaId = dramaId {
            Alamofire.request(Router.dramaReviews(id: dramaId, page: 0)).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        self.reviews.removeAll()
                        for review in json["data"].arrayValue {
                            self.reviews.append(Review(json: review))
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
        if let dramaId = dramaId {
            Alamofire.request(Router.dramaReviews(id: dramaId, page: currentPage + 1)).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        for review in json["data"].arrayValue {
                            self.reviews.append(Review(json: review))
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
        let review = reviews[(indexPath as NSIndexPath).row]
        cell.userName.setTitle(review.user!.name, for: UIControlState())
        if let episode = review.episode {
            cell.episodeTitle.setTitle(episode.title, for: UIControlState())
            cell.episodeTitle.isHidden = false
        } else {
            cell.episodeTitle.setTitle("", for: UIControlState())
            cell.episodeTitle.isHidden = true
        }
        cell.createdAt.text = review.createdAt
        cell.title.text = review.title
        cell.content.text = review.content
        cell.userName.tag = (indexPath as NSIndexPath).row
        cell.episodeTitle.tag = (indexPath as NSIndexPath).row
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEpisode" {
            let episodeViewController = segue.destination as! EpisodeViewController
            if let button = sender as? UIButton {
                episodeViewController.episodeId = reviews[button.tag].episodeId
            }
        } else if segue.identifier == "ShowUser" {
            let userViewController = segue.destination as! UserViewController
            if let button = sender as? UIButton {
                userViewController.userId = reviews[button.tag].userId
            }
        }
    }

}
