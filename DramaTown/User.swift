import Foundation
import SwiftyJSON

class User {
    var id = 0
    var name = ""
    var introduction = ""
    var reviews = 0
    var favorite0 = 0
    var favorite1 = 0
    var favorite2 = 0
    var favorite3 = 0
    var favorite4 = 0
    var epfav0 = 0
    var epfav2 = 0
    var epfav4 = 0
    var createdAt = ""
    
    init(json: JSON) {
        if json["id"] != nil {
            id = Int(json["id"].stringValue)!
        }
        name = json["name"].stringValue
        introduction = json["introduction"].stringValue
        if json["reviews"] != nil {
            reviews = Int(json["reviews"].stringValue)!
        }
        if json["favorite0"] != nil {
            favorite0 = Int(json["favorite0"].stringValue)!
        }
        if json["favorite1"] != nil {
            favorite1 = Int(json["favorite1"].stringValue)!
        }
        if json["favorite2"] != nil {
            favorite2 = Int(json["favorite2"].stringValue)!
        }
        if json["favorite3"] != nil {
            favorite3 = Int(json["favorite3"].stringValue)!
        }
        if json["favorite4"] != nil {
            favorite4 = Int(json["favorite4"].stringValue)!
        }
        if json["epfav0"] != nil {
            epfav0 = Int(json["epfav0"].stringValue)!
        }
        if json["epfav2"] != nil {
            epfav2 = Int(json["epfav2"].stringValue)!
        }
        if json["epfav4"] != nil {
            epfav4 = Int(json["epfav4"].stringValue)!
        }
        createdAt = json["created_at"].stringValue
    }
}