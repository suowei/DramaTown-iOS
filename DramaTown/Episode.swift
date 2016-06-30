import Foundation
import SwiftyJSON

class Episode {
    
    var id = 0
    var dramaId = 0
    var title = ""
    var alias = ""
    var releaseDate = ""
    var url = ""
    var sc = ""
    var duration = 0
    var posterUrl = ""
    var introduction = ""
    var reviews = 0
    var drama: Drama? = nil
    var userFavorite: Epfav? = nil
    
    init(json: JSON) {
        if json["id"] != nil {
            id = Int(json["id"].stringValue)!
        }
        if json["drama_id"] != nil {
            dramaId = Int(json["drama_id"].stringValue)!
        }
        title = json["title"].stringValue
        alias = json["alias"].stringValue
        releaseDate = json["release_date"].stringValue
        url = json["url"].stringValue
        sc = json["sc"].stringValue
        if json["duration"] != nil {
            duration = Int(json["duration"].stringValue)!
        }
        posterUrl = json["poster_url"].stringValue
        introduction = json["introduction"].stringValue
        if json["reviews"] != nil {
            reviews = Int(json["reviews"].stringValue)!
        }
        if json["drama"] != nil {
            drama = Drama(json: json["drama"])
        }
        if json["userFavorite"] != nil {
            userFavorite = Epfav(json: json["userFavorite"])
        }
    }
}