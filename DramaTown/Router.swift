import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = "http://saoju.net/api/"
    
    case GetNewEpisodes(page: Int)
    
    case ReadEpisode(id: Int)
    case EpisodeReviews(id: Int, page: Int)
    
    case DramaIndex(page: Int)
    case ReadDrama(id: Int)
    case DramaReviews(id: Int, page: Int)
    
    case ReviewIndex(page: Int)
    case CreateReview(token: String, dramaId: Int, episodeId: Int?, title: String, content: String, visible: Int)
    
    case ReadUser(id: Int)
    case UserEpfavs(id: Int, type: Int, page: Int)
    case UserFavorites(id: Int, type: Int, page: Int)
    case UserReviews(id: Int, page: Int)
    
    case Search(keyword: String)
    
    case GetToken()
    
    case Login(token: String, email: String, password: String, remember: String)
    
    case CreateEpfav(token: String, episodeId: Int, type: Int, rating: Double)
    case UpdateEpfav(token: String, episodeId: Int, type: Int, rating: Double)
    case DestroyEpfav(token: String, episodeId: Int)
    case CreateEpfavReview(token: String, episodeId: Int, dramaId: Int, type: Int, rating: Double,
        title: String, content: String, visible: Int)
    case EditEpfavReview(episodeId: Int)
    case UpdateEpfavReview(token: String, episodeId: Int, dramaId: Int, type: Int, rating: Double,
        title: String, content: String, visible: Int)
    
    case CreateFavorite(token: String, dramaId: Int, type: Int, rating: Double, tags: String)
    case UpdateFavorite(token: String, id: Int, type: Int, rating: Double, tags: String)
    case DestroyFavorite(token: String, id: Int)
    case CreateFavoriteReview(token: String, dramaId: Int, type: Int, rating: Double, tags: String,
        title: String, content: String, visible: Int)
    case EditFavoriteReview(dramaId: Int)
    case UpdateFavoriteReview(token: String, dramaId: Int, type: Int, rating: Double, tags: String,
        title: String, content: String, visible: Int)
    
    var method: Alamofire.Method {
        switch self {
        case .GetNewEpisodes:
            return .GET
        case .ReadEpisode:
            return .GET
        case .EpisodeReviews:
            return .GET
        case .DramaIndex:
            return .GET
        case .ReadDrama:
            return .GET
        case .DramaReviews:
            return .GET
        case .ReviewIndex:
            return .GET
        case .CreateReview:
            return .POST
        case .ReadUser:
            return .GET
        case .UserEpfavs:
            return .GET
        case .UserFavorites:
            return .GET
        case .UserReviews:
            return .GET
        case .Search:
            return .GET
        case .GetToken:
            return .GET
        case .Login:
            return .POST
        case .CreateEpfav:
            return .POST
        case .UpdateEpfav:
            return .PUT
        case .DestroyEpfav:
            return .DELETE
        case .CreateEpfavReview:
            return .POST
        case .EditEpfavReview:
            return .GET
        case .UpdateEpfavReview:
            return .PUT
        case .CreateFavorite:
            return .POST
        case .UpdateFavorite:
            return .PUT
        case .DestroyFavorite:
            return .DELETE
        case .CreateFavoriteReview:
            return .POST
        case .EditFavoriteReview:
            return .GET
        case .UpdateFavoriteReview:
            return .PUT
        }
    }
    
    var path: String {
        switch self {
        case .GetNewEpisodes:
            return "newepisodes"
        case .ReadEpisode(let id):
            return "episode/\(id)"
        case .EpisodeReviews(let id, _):
            return "episode/\(id)/reviews"
        case .DramaIndex:
            return "drama"
        case .ReadDrama(let id):
            return "drama/\(id)"
        case .DramaReviews(let id, _):
            return "drama/\(id)/reviews"
        case .ReviewIndex:
            return "review"
        case .CreateReview:
            return "review"
        case .ReadUser(let id):
            return "user/\(id)"
        case .UserEpfavs(let id, let type, _):
            return "user/\(id)/epfavs/\(type)"
        case .UserFavorites(let id, let type, _):
            return "user/\(id)/favorites/\(type)"
        case .UserReviews(let id, _):
            return "user/\(id)/reviews"
        case .Search:
            return "search"
        case .GetToken:
            return "csrftoken"
        case .Login:
            return "auth/login"
        case .CreateEpfav:
            return "epfav"
        case .UpdateEpfav(_, let episodeId, _, _):
            return "epfav/\(episodeId)"
        case .DestroyEpfav(_, let episodeId):
            return "epfav/\(episodeId)"
        case .CreateEpfavReview:
            return "epfav2"
        case .UpdateEpfavReview(_, let episodeId, _, _, _, _, _, _):
            return "epfav2/\(episodeId)"
        case .EditEpfavReview(let episodeId):
            return "epfav/\(episodeId)/edit"
        case .CreateFavorite:
            return "favorite"
        case .UpdateFavorite(_, let id, _, _, _):
            return "favorite/\(id)"
        case .DestroyFavorite(_, let id):
            return "favorite/\(id)"
        case .CreateFavoriteReview:
            return "favorite2"
        case .UpdateFavoriteReview(_, let dramaId, _, _, _, _, _, _):
            return "favorite2/\(dramaId)"
        case .EditFavoriteReview(let dramaId):
            return "favorite/\(dramaId)/edit"
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Router.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .GetNewEpisodes(let page):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["page": page]).0
        case .DramaIndex(let page):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["page": page]).0
        case .ReviewIndex(let page):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["page": page]).0
        case .CreateReview(let token, let dramaId, let episodeId, let title, let content, let visible):
            if let episodeId = episodeId {
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token, "drama_id": dramaId, "episode_id": episodeId, "title": title, "content": content, "visible": visible]).0
            } else {
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token, "drama_id": dramaId, "title": title, "content": content, "visible": visible]).0
            }
        case .EpisodeReviews(_, let page):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["page": page]).0
        case .DramaReviews(_, let page):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["page": page]).0
        case .UserEpfavs(_, _, let page):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["page": page]).0
        case .UserFavorites(_, _, let page):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["page": page]).0
        case .UserReviews(_, let page):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["page": page]).0
        case .Search(let keyword):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["keyword": keyword]).0
        case .Login(let token, let email, let password, let remember):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token, "email": email, "password": password, "remember": remember]).0
        case .CreateEpfav(let token, let episodeId, let type, let rating):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token, "episode_id": episodeId, "type": type, "rating": rating]).0
        case .UpdateEpfav(let token, _, let type, let rating):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token, "type": type, "rating": rating]).0
        case .DestroyEpfav(let token, _):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token]).0
        case .CreateEpfavReview(let token, let episodeId, let dramaId, let type, let rating, let title, let content, let visible):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token, "episode_id": episodeId, "drama_id": dramaId, "type": type, "rating": rating, "title": title, "content": content, "visible": visible]).0
        case .UpdateEpfavReview(let token, _, let dramaId, let type, let rating, let title, let content, let visible):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token, "drama_id": dramaId, "type": type, "rating": rating, "title": title, "content": content, "visible": visible]).0
        case .CreateFavorite(let token, let dramaId, let type, let rating, let tags):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token, "drama_id": dramaId, "type": type, "rating": rating, "tags": tags]).0
        case .UpdateFavorite(let token, _, let type, let rating, let tags):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token, "type": type, "rating": rating, "tags": tags]).0
        case .DestroyFavorite(let token, _):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token]).0
        case .CreateFavoriteReview(let token, let dramaId, let type, let rating, let tags, let title, let content, let visible):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token, "drama_id": dramaId, "type": type, "rating": rating, "tags": tags, "title": title, "content": content, "visible": visible]).0
        case .UpdateFavoriteReview(let token, _, let type, let rating, let tags, let title, let content, let visible):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["_token": token, "type": type, "rating": rating, "tags": tags, "title": title, "content": content, "visible": visible]).0
        default:
            return mutableURLRequest
        }
    }
}
