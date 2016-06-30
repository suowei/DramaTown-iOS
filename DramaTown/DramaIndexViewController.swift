import UIKit
import SwiftyJSON
import MJRefresh
import Alamofire

class DramaIndexViewController: UITableViewController {

    var dramas = [Drama]()
    
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
        tableView.mj_header.beginRefreshing()
    }
    
    func loadNewData() {
        Alamofire.request(Router.DramaIndex(page: 0)).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.dramas.removeAll()
                    for drama in json["data"].arrayValue {
                        self.dramas.append(Drama(json: drama))
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
        Alamofire.request(Router.DramaIndex(page: currentPage + 1)).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    for drama in json["data"].arrayValue {
                        self.dramas.append(Drama(json: drama))
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dramas.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DramaCell", forIndexPath: indexPath)
        let drama = dramas[indexPath.row]
        cell.textLabel?.text = drama.title
        var info = "\(drama.cv)\n\(drama.typeString)，\(drama.eraString)"
        if drama.genre != "" {
            info += "，\(drama.genre)"
        }
        info += "，\(drama.originalString)，\(drama.count)期，\(drama.stateString)"
        cell.detailTextLabel?.text = info
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDrama" {
            let dramaViewController = segue.destinationViewController as! DramaViewController
            if let selectedCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCell)!
                let selectedDrama = dramas[indexPath.row]
                dramaViewController.dramaId = selectedDrama.id
            }
        }
    }

}
