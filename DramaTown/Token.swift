import Foundation
import SwiftyJSON

class Token {
    var token = ""
    
    init(json: JSON) {
        token = json["token"].stringValue
    }
}