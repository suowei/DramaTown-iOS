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
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        login()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func login() {
        loginButton.isEnabled = false
        Alamofire.request(Router.getToken()).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let token = Token(json: JSON(value)).token
                    let email = self.email.text!
                    let password = self.password.text!
                    Alamofire.request(Router.login(token: token, email: email, password: password, remember: "on")).validate(statusCode: 200...400).responseJSON { response in
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let user = User(json: JSON(value))
                                UserDefaults.standard.set(user.id, forKey: "UserId")
                                self.performSegue(withIdentifier: self.unwindSegueIdentifier, sender: nil)
                            }
                        case .failure(let error):
                            self.fail()
                            print(error)
                        }
                    }
                }
            case .failure(let error):
                self.loginButton.isEnabled = true
                print(error)
            }
        }
    }
    
    func fail() {
        self.loginButton.isEnabled = true
        let alertController = UIAlertController(title: "登录失败", message: "请检查输入", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
