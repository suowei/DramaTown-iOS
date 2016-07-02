import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var unwindSegueIdentifier = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        login()
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func login() {
        loginButton.enabled = false
        Alamofire.request(Router.GetToken()).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let token = Token(json: JSON(value)).token
                    let email = self.email.text!
                    let password = self.password.text!
                    Alamofire.request(Router.Login(token: token, email: email, password: password, remember: "on")).validate(statusCode: 200...400).responseJSON { response in
                        switch response.result {
                        case .Success:
                            if let value = response.result.value {
                                let user = User(json: JSON(value))
                                NSUserDefaults.standardUserDefaults().setInteger(user.id, forKey: "UserId")
                                self.performSegueWithIdentifier(self.unwindSegueIdentifier, sender: nil)
                            }
                        case .Failure(let error):
                            self.fail()
                            print(error)
                        }
                    }
                }
            case .Failure(let error):
                self.loginButton.enabled = true
                print(error)
            }
        }
    }
    
    func fail() {
        self.loginButton.enabled = true
        let alertController = UIAlertController(title: "登录失败", message: "请检查输入", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "确定", style: .Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}
