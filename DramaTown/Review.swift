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
        if json["id"] != nil {
            id = Int(json["id"].stringValue)!
        }
        if json["drama_id"] != nil {
            dramaId = Int(json["drama_id"].stringValue)!
        }
        if json["episode_id"] != nil {
            episodeId = Int(json["episode_id"].stringValue)!
        }
        if json["user_id"] != nil {
            userId = Int(json["user_id"].stringValue)!
        }
        title = json["title"].stringValue
        content = json["content"].stringValue
        createdAt = json["created_at"].stringValue
        if json["drama"] != nil {
            drama = Drama(json: json["drama"])
        }
        if json["user"] != nil {
            user = User(json: json["user"])
        }
        if json["episode"] != nil {
            episode = Episode(json: json["episode"])
        }
    }
}