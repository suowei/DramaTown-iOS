import Foundation

import SwiftyJSON

class TagMap {
    var dramaId = 0
    var tagId = 0
    var count = 0
    var tag: Tag? = nil
    
    init(json: JSON) {
        if json["drama_id"] != JSON.null {
            dramaId = Int(json["drama_id"].stringValue)!
        }
        tagId = Int(json["tag_id"].stringValue)!
        count = Int(json["count"].stringValue)!
        if json["tag"] != JSON.null {
            tag = Tag(json: json["tag"])
        }
    }
}
