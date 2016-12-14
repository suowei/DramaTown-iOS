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
            Alamofire.request(Router.search(keyword: keyword)).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        self.dramas.removeAll()
                        for drama in json.arrayValue {
                            self.dramas.append(Drama(json: drama))
                        }
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
                self.tableView.mj_header.endRefreshing()
            }
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
        cell.detailTextLabel?.text = drama.cv
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        keyword = searchBar.text
        tableView.mj_header.beginRefreshing()
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
