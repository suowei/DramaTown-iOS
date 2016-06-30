import UIKit
import Alamofire
import SwiftyJSON

class UserViewController: UITableViewController {
    
    var userId: Int?
    var user: User? = nil
    var isRootView = false
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var introduction: UILabel!
    @IBOutlet weak var epfav0: UITableViewCell!
    @IBOutlet weak var epfav2: UITableViewCell!
    @IBOutlet weak var epfav4: UITableViewCell!
    @IBOutlet weak var favorite0: UITableViewCell!
    @IBOutlet weak var favorite1: UITableViewCell!
    @IBOutlet weak var favorite2: UITableViewCell!
    @IBOutlet weak var favorite3: UITableViewCell!
    @IBOutlet weak var favorite4: UITableViewCell!
    @IBOutlet weak var reviews: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if userId == nil {
            isRootView = true
            if let userId = NSUserDefaults.standardUserDefaults().valueForKey("UserId") as? Int {
                self.userId = userId
                refresh()
            } else {
                performSegueWithIdentifier("Login", sender: nil)
            }
        }
    }
    
    func refresh() {
        if let userId = userId {
            Alamofire.request(Router.ReadUser(id: userId)).validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        self.user = User(json: JSON(value))
                        self.setUpViews()
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func setUpViews() {
        if let user = user {
            name.text = user.name
            createdAt.text = "\(user.createdAt) 加入"
            if user.introduction.isEmpty {
                introduction.text = ""
            } else {
                introduction.text = "自我介绍：\(user.introduction)"
            }
            epfav0.textLabel?.text = "想听：\(user.epfav0)期"
            epfav2.textLabel?.text = "听过：\(user.epfav2)期"
            epfav4.textLabel?.text = "抛弃：\(user.epfav4)期"
            favorite0.textLabel?.text = "想听：\(user.favorite0)部"
            favorite1.textLabel?.text = "在追：\(user.favorite1)部"
            favorite2.textLabel?.text = "听过：\(user.favorite2)部"
            favorite3.textLabel?.text = "搁置：\(user.favorite3)部"
            favorite4.textLabel?.text = "抛弃：\(user.favorite4)部"
            reviews.textLabel?.text = "剧集评论：\(user.reviews)篇"
            tableView.reloadData()
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return isRootView ? 5 : 4
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEpfavs0" {
            let userEpfavsViewController = segue.destinationViewController as! UserEpfavsViewController
            userEpfavsViewController.userId = userId
            userEpfavsViewController.type = 0
        } else if segue.identifier == "ShowEpfavs2" {
            let userEpfavsViewController = segue.destinationViewController as! UserEpfavsViewController
            userEpfavsViewController.userId = userId
            userEpfavsViewController.type = 2
        } else if segue.identifier == "ShowEpfavs4" {
            let userEpfavsViewController = segue.destinationViewController as! UserEpfavsViewController
            userEpfavsViewController.userId = userId
            userEpfavsViewController.type = 4
        } else if segue.identifier == "ShowFavorites0" {
            let userFavoritesViewController = segue.destinationViewController as! UserFavoritesViewController
            userFavoritesViewController.userId = userId
            userFavoritesViewController.type = 0
        } else if segue.identifier == "ShowFavorites1" {
            let userFavoritesViewController = segue.destinationViewController as! UserFavoritesViewController
            userFavoritesViewController.userId = userId
            userFavoritesViewController.type = 1
        } else if segue.identifier == "ShowFavorites2" {
            let userFavoritesViewController = segue.destinationViewController as! UserFavoritesViewController
            userFavoritesViewController.userId = userId
            userFavoritesViewController.type = 2
        } else if segue.identifier == "ShowFavorites3" {
            let userFavoritesViewController = segue.destinationViewController as! UserFavoritesViewController
            userFavoritesViewController.userId = userId
            userFavoritesViewController.type = 3
        } else if segue.identifier == "ShowFavorites4" {
            let userFavoritesViewController = segue.destinationViewController as! UserFavoritesViewController
            userFavoritesViewController.userId = userId
            userFavoritesViewController.type = 4
        } else if segue.identifier == "ShowReviews" {
            let userReviewsViewController = segue.destinationViewController as! UserReviewsViewController
            userReviewsViewController.userId = userId
        } else if segue.identifier == "Login" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.unwindSegueIdentifier = "UnWindToUserViewController"
            loginViewController.navigationItem.hidesBackButton = true
        } else if segue.identifier == "Logout" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.unwindSegueIdentifier = "UnWindToUserViewController"
            loginViewController.navigationItem.hidesBackButton = true
            NSUserDefaults.standardUserDefaults().removeObjectForKey("UserId")
            for cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies! {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
    }
    
    @IBAction func unwindToUserViewController(sender: UIStoryboardSegue) {
        if (sender.sourceViewController as? LoginViewController) != nil {
            userId = NSUserDefaults.standardUserDefaults().valueForKey("UserId") as? Int
            refresh()
        }
    }
    
}
