import Foundation
import SwiftyJSON

class Tag {
    var id = 0
    var name = ""
    
    init(json: JSON) {
        id = Int(json["id"].stringValue)!
        name = json["name"].stringValue
    }
}
