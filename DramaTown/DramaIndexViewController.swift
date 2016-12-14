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
        Alamofire.request(Router.dramaIndex(page: 0)).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.dramas.removeAll()
                    for drama in json["data"].arrayValue {
                        self.dramas.append(Drama(json: drama))
                    }
                    self.tableView.reloadData()
                    self.currentPage = json["current_page"].intValue
                }
            case .failure(let error):
                print(error)
            }
            self.tableView.mj_header.endRefreshing()
        }
    }
    
    func loadMoreData() {
        Alamofire.request(Router.dramaIndex(page: currentPage + 1)).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    for drama in json["data"].arrayValue {
                        self.dramas.append(Drama(json: drama))
                    }
                    self.tableView.reloadData()
                    self.currentPage = json["current_page"].intValue
                }
            case .failure(let error):
                print(error)
            }
            self.tableView.mj_footer.endRefreshing()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dramas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DramaCell", for: indexPath)
        let drama = dramas[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = drama.title
        var info = "\(drama.cv)\n\(drama.typeString)，\(drama.eraString)"
        if drama.genre != "" {
            info += "，\(drama.genre)"
        }
        info += "，\(drama.originalString)，\(drama.count)期，\(drama.stateString)"
        cell.detailTextLabel?.text = info
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDrama" {
            let dramaViewController = segue.destination as! DramaViewController
            if let selectedCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPath(for: selectedCell)!
                let selectedDrama = dramas[(indexPath as NSIndexPath).row]
                dramaViewController.dramaId = selectedDrama.id
            }
        }
    }

}
