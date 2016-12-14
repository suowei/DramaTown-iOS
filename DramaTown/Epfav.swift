import Foundation
import SwiftyJSON

class Epfav {
    var episodeId = 0
    var userId = 0
    var type = 0
    var typeString: String {
        get {
            switch type {
            case 0:
                return "想听"
            case 2:
                return "听过"
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
    var updatedAt = ""
    var episode: Episode? = nil
    
    init(json: JSON) {
        if json["episode_id"] != JSON.null {
            episodeId = Int(json["episode_id"].stringValue)!
        }
        type = Int(json["type"].stringValue)!
        rating = Double(json["rating"].stringValue)!
        updatedAt = json["updated_at"].stringValue
        if json["episode"] != JSON.null {
            episode = Episode(json: json["episode"])
        }
    }
    
    init(type: Int, rating: Double) {
        self.type = type
        self.rating = rating
    }
}
