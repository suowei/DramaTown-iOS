import UIKit
import Alamofire
import SwiftyJSON
import MJRefresh

class NewEpisodesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var newEpisodes = [[JSON]]()
    
    var currentPage = 0
    
    var today = ""
    var yesterday = ""
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
        
        tableView.mj_header.beginRefreshing()
    }
    
    func loadNewData() {
        let now = Date()
        today = dateFormatter.string(from: now)
        yesterday = dateFormatter.string(from: Date(timeInterval: -86400, since: now))
        Alamofire.request(Router.getNewEpisodes(page: 0)).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.newEpisodes.removeAll()
                    self.appendEpisodes(json["data"].arrayValue)
                    self.tableView.reloadData()
                    self.currentPage = json["current_page"].intValue
                }
            case .failure(let error):
                print(error)
            }
            self.tableView.mj_header.endRefreshing()
        }
    }
    
    func appendEpisodes(_ episodes: [JSON]) {
        for episode in episodes {
            if newEpisodes.count == 0 || newEpisodes[newEpisodes.count - 1][0]["releaseDate"].stringValue != episode["releaseDate"].stringValue {
                newEpisodes.append([episode])
            } else {
                newEpisodes[newEpisodes.count - 1].append(episode)
            }
        }
    }
    
    func loadMoreData() {
        Alamofire.request(Router.getNewEpisodes(page: currentPage + 1)).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.appendEpisodes(json["data"].arrayValue)
                    self.tableView.reloadData()
                    self.currentPage = json["current_page"].intValue
                }
            case .failure(let error):
                print(error)
            }
            self.tableView.mj_footer.endRefreshing()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return newEpisodes.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newEpisodes[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = newEpisodes[section][0]["releaseDate"].stringValue
        switch date {
        case today:
            return "今天"
        case yesterday:
            return "昨天"
        default:
            return date
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewEpisodeCell", for: indexPath) as! NewEpisodesTableViewCell
        var episode = newEpisodes[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        let drama = Drama(json: episode)
        cell.title.text = drama.eraString + drama.typeString
            + "《" + episode["dramaTitle"].stringValue + "》"
            + episode["episodeTitle"].stringValue
        cell.duration.text = episode["duration"].stringValue + "'"
        cell.cv.text = episode["sc"].stringValue
        cell.original.text = drama.originalString
        if episode["state"].stringValue == "1" {
            cell.backgroundColor = Color.lightBlue
            cell.title.textColor = Color.primaryColor
            cell.title.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightBlack)
            cell.cv.textColor = Color.primaryColor
        } else {
            cell.backgroundColor = UIColor.white
            cell.title.textColor = UIColor.black
            cell.title.font = UIFont.systemFont(ofSize: 16)
            cell.cv.textColor = UIColor.black
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let episodeViewController = segue.destination as! EpisodeViewController
            if let selectedCell = sender as? NewEpisodesTableViewCell {
                let indexPath = tableView.indexPath(for: selectedCell)!
                let selectedEpisode = newEpisodes[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                episodeViewController.episodeId = Int(selectedEpisode["episodeId"].stringValue)
            }
        }
    }
}

