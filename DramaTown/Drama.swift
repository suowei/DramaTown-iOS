import Foundation
import SwiftyJSON

class Drama {
    
    var id = 0
    var title = ""
    var alias = ""
    var type = 0
    var typeString: String {
        get {
            switch type {
            case 0:
                return "耽美"
            case 1:
                return "全年龄"
            case 2:
                return "言情"
            case 3:
                return "百合"
            default:
                return "未知类型"
            }
        }
    }
    var era = 0
    var eraString: String {
        get {
            switch era {
            case 0:
                return "现代"
            case 1:
                return "古风"
            case 2:
                return "民国"
            case 3:
                return "未来"
            case 4:
                return "其他时代"
            default:
                return "未知时代"
            }
        }
    }
    var genre = ""
    var original = false
    var originalString: String {
        get {
            return original ? "原创" : "改编"
        }
    }
    var count = 0
    var state = 0
    var stateString: String {
        get {
            switch state {
            case 0:
                return "连载"
            case 1:
                return "完结"
            case 2:
                return "已坑"
            default:
                return "未知状态"
            }
        }
    }
    var cv = ""
    var introduction = ""
    var reviews = 0
    var commtags: [TagMap]? = nil
    var episodes: [Episode]? = nil
    var userFavorite: Favorite? = nil
    var userTags: [TagMap]? = nil
    
    init(json: JSON) {
        if json["id"] != nil {
            id = Int(json["id"].stringValue)!
        }
        title = json["title"].stringValue
        alias = json["alias"].stringValue
        if json["type"] != nil {
            type = Int(json["type"].stringValue)!
        }
        if json["era"] != nil {
            era = Int(json["era"].stringValue)!
        }
        genre = json["genre"].stringValue
        original = json["original"].stringValue == "1" ? true : false
        if json["count"] != nil {
            count = Int(json["count"].stringValue)!
        }
        if json["state"] != nil {
            count = Int(json["state"].stringValue)!
        }
        cv = json["sc"].stringValue
        introduction = json["introduction"].stringValue
        if json["reviews"] != nil {
            reviews = Int(json["reviews"].stringValue)!
        }
        if json["commtags"] != nil {
            commtags = [TagMap]()
            for tagmap in json["commtags"].arrayValue {
                commtags?.append(TagMap(json: tagmap))
            }
        }
        if json["episodes"] != nil {
            episodes = [Episode]()
            for episode in json["episodes"].arrayValue {
                episodes?.append(Episode(json: episode))
            }
        }
        if json["userFavorite"] != nil {
            userFavorite = Favorite(json: json["userFavorite"])
        }
        if json["userTags"] != nil {
            userTags = [TagMap]()
            for tagmap in json["userTags"].arrayValue {
                userTags?.append(TagMap(json: tagmap))
            }
        }
    }
    
}