import Foundation
import SwiftyJSON

class Review {
    
    var id = 0
    var dramaId = 0
    var episodeId = 0
    var userId = 0
    var title = ""
    var content = ""
    var visible = 1
    var createdAt = ""
    var drama: Drama? = nil
    var user: User? = nil
    var episode: Episode? = nil
    
    init(json: JSON) {
        if json["id"] != JSON.null {
            id = Int(json["id"].stringValue)!
        }
        if json["drama_id"] != JSON.null {
            dramaId = Int(json["drama_id"].stringValue)!
        }
        if json["episode_id"] != JSON.null {
            episodeId = Int(json["episode_id"].stringValue)!
        }
        if json["user_id"] != JSON.null {
            userId = Int(json["user_id"].stringValue)!
        }
        title = json["title"].stringValue
        content = json["content"].stringValue
        createdAt = json["created_at"].stringValue
        if json["drama"] != JSON.null {
            drama = Drama(json: json["drama"])
        }
        if json["user"] != JSON.null {
            user = User(json: json["user"])
        }
        if json["episode"] != JSON.null {
            episode = Episode(json: json["episode"])
        }
    }
}
