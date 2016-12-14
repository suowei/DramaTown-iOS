import Foundation

import SwiftyJSON

class Favorite {
    var id = 0
    var dramaId = 0
    var userId = 0
    var type = 0
    var typeString: String {
        get {
            switch type {
            case 0:
                return "想听"
            case 1:
                return "在追"
            case 2:
                return "听过"
            case 3:
                return "搁置"
            case 4:
                return "抛弃"
            default:
                return "未知类型"
            }
        }
    }
    var rating = 0.0
    var ratingString: String {
        get {
            switch rating {
            case 0.5:
                return "半星"
            case 1.0:
                return "一星"
            case 1.5:
                return "一星半"
            case 2.0:
                return "二星"
            case 2.5:
                return "二星半"
            case 3.0:
                return "三星"
            case 3.5:
                return "三星半"
            case 4.0:
                return "四星"
            case 4.5:
                return "四星半"
            case 5.0:
                return "五星"
            default:
                return "未评分"
            }
        }
    }
    var tags = ""
    var updatedAt = ""
    var drama: Drama? = nil
    
    init(json: JSON) {
        if json["id"] != JSON.null {
            id = Int(json["id"].stringValue)!
        }
        if json["drama_id"] != JSON.null {
            dramaId = Int(json["drama_id"].stringValue)!
        }
        type = Int(json["type"].stringValue)!
        rating = Double(json["rating"].stringValue)!
        tags = json["tags"].stringValue
        updatedAt = json["updated_at"].stringValue
        if json["drama"] != JSON.null {
            drama = Drama(json: json["drama"])
        }
    }
    
    init(type: Int, rating: Double, tags: String) {
        self.type = type
        self.rating = rating
        self.tags = tags
    }
}
