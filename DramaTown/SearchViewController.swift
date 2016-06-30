import UIKit
import Alamofire
import MJRefresh
import SwiftyJSON

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    var keyword: String?
    var dramas = [Drama]()

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.text = keyword

        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        tableView.mj_header.beginRefreshing()
    }
    
    func loadNewData() {
        if let keyword = keyword {
            Alamofire.request(Router.Search(keyword: keyword)).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        self.dramas.removeAll()
                        for drama in json.arrayValue {
                            self.dramas.append(Drama(json: drama))
                        }
                        self.tableView.reloadData()
                    }
                case .Failure(let error):
                    print(error)
                }
                self.tableView.mj_header.endRefreshing()
            }
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
        cell.detailTextLabel?.text = drama.cv
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        keyword = searchBar.text
        tableView.mj_header.beginRefreshing()
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
