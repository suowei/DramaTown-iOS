import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = "https://saoju.net/api/"
    
    case getNewEpisodes(page: Int)
    
    case readEpisode(id: Int)
    case episodeReviews(id: Int, page: Int)
    
    case dramaIndex(page: Int)
    case readDrama(id: Int)
    case dramaReviews(id: Int, page: Int)
    
    case reviewIndex(page: Int)
    case createReview(token: String, dramaId: Int, episodeId: Int?, title: String, content: String, visible: Int)
    case updateReview(token: String, reviewId: Int, title: String, content: String, visible: Int)
    case destroyReview(token: String, reviewId: Int)
    
    case readUser(id: Int)
    case userEpfavs(id: Int, type: Int, page: Int)
    case userFavorites(id: Int, type: Int, page: Int)
    case userReviews(id: Int, page: Int)
    
    case search(keyword: String)
    
    case getToken()
    
    case login(token: String, email: String, password: String, remember: String)
    
    case createEpfav(token: String, episodeId: Int, type: Int, rating: Double)
    case updateEpfav(token: String, episodeId: Int, type: Int, rating: Double)
    case destroyEpfav(token: String, episodeId: Int)
    case createEpfavReview(token: String, episodeId: Int, dramaId: Int, type: Int, rating: Double,
        title: String, content: String, visible: Int)
    case editEpfavReview(episodeId: Int)
    case updateEpfavReview(token: String, episodeId: Int, dramaId: Int, type: Int, rating: Double,
        title: String, content: String, visible: Int)
    
    case createFavorite(token: String, dramaId: Int, type: Int, rating: Double, tags: String)
    case updateFavorite(token: String, id: Int, type: Int, rating: Double, tags: String)
    case destroyFavorite(token: String, id: Int)
    case createFavoriteReview(token: String, dramaId: Int, type: Int, rating: Double, tags: String,
        title: String, content: String, visible: Int)
    case editFavoriteReview(dramaId: Int)
    case updateFavoriteReview(token: String, dramaId: Int, type: Int, rating: Double, tags: String,
        title: String, content: String, visible: Int)
    
    var method: HTTPMethod {
        switch self {
        case .getNewEpisodes:
            return .get
        case .readEpisode:
            return .get
        case .episodeReviews:
            return .get
        case .dramaIndex:
            return .get
        case .readDrama:
            return .get
        case .dramaReviews:
            return .get
        case .reviewIndex:
            return .get
        case .createReview:
            return .post
        case .updateReview:
            return .put
        case .destroyReview:
            return .delete
        case .readUser:
            return .get
        case .userEpfavs:
            return .get
        case .userFavorites:
            return .get
        case .userReviews:
            return .get
        case .search:
            return .get
        case .getToken:
            return .get
        case .login:
            return .post
        case .createEpfav:
            return .post
        case .updateEpfav:
            return .put
        case .destroyEpfav:
            return .delete
        case .createEpfavReview:
            return .post
        case .editEpfavReview:
            return .get
        case .updateEpfavReview:
            return .put
        case .createFavorite:
            return .post
        case .updateFavorite:
            return .put
        case .destroyFavorite:
            return .delete
        case .createFavoriteReview:
            return .post
        case .editFavoriteReview:
            return .get
        case .updateFavoriteReview:
            return .put
        }
    }
    
    var path: String {
        switch self {
        case .getNewEpisodes:
            return "newepisodes"
        case .readEpisode(let id):
            return "episode/\(id)"
        case .episodeReviews(let id, _):
            return "episode/\(id)/reviews"
        case .dramaIndex:
            return "drama"
        case .readDrama(let id):
            return "drama/\(id)"
        case .dramaReviews(let id, _):
            return "drama/\(id)/reviews"
        case .reviewIndex:
            return "review"
        case .createReview:
            return "review"
        case .updateReview(_, let id, _, _, _):
            return "review/\(id)"
        case .destroyReview(_, let id):
            return "review/\(id)"
        case .readUser(let id):
            return "user/\(id)"
        case .userEpfavs(let id, let type, _):
            return "user/\(id)/epfavs/\(type)"
        case .userFavorites(let id, let type, _):
            return "user/\(id)/favorites/\(type)"
        case .userReviews(let id, _):
            return "user/\(id)/reviews"
        case .search:
            return "search"
        case .getToken:
            return "csrftoken"
        case .login:
            return "auth/login"
        case .createEpfav:
            return "epfav"
        case .updateEpfav(_, let episodeId, _, _):
            return "epfav/\(episodeId)"
        case .destroyEpfav(_, let episodeId):
            return "epfav/\(episodeId)"
        case .createEpfavReview:
            return "epfav2"
        case .updateEpfavReview(_, let episodeId, _, _, _, _, _, _):
            return "epfav2/\(episodeId)"
        case .editEpfavReview(let episodeId):
            return "epfav/\(episodeId)/edit"
        case .createFavorite:
            return "favorite"
        case .updateFavorite(_, let id, _, _, _):
            return "favorite/\(id)"
        case .destroyFavorite(_, let id):
            return "favorite/\(id)"
        case .createFavoriteReview:
            return "favorite2"
        case .updateFavoriteReview(_, let dramaId, _, _, _, _, _, _):
            return "favorite2/\(dramaId)"
        case .editFavoriteReview(let dramaId):
            return "favorite/\(dramaId)/edit"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .getNewEpisodes(let page):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["page": page])
        case .dramaIndex(let page):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["page": page])
        case .reviewIndex(let page):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["page": page])
        case .createReview(let token, let dramaId, let episodeId, let title, let content, let visible):
            if let episodeId = episodeId {
                urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "drama_id": dramaId, "episode_id": episodeId, "title": title, "content": content, "visible": visible])
            } else {
                urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "drama_id": dramaId, "title": title, "content": content, "visible": visible])
            }
        case .updateReview(let token, _, let title, let content, let visible):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "title": title, "content": content, "tags": visible])
        case .destroyReview(let token, _):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token])
        case .episodeReviews(_, let page):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["page": page])
        case .dramaReviews(_, let page):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["page": page])
        case .userEpfavs(_, _, let page):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["page": page])
        case .userFavorites(_, _, let page):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["page": page])
        case .userReviews(_, let page):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["page": page])
        case .search(let keyword):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["keyword": keyword])
        case .login(let token, let email, let password, let remember):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "email": email, "password": password, "remember": remember])
        case .createEpfav(let token, let episodeId, let type, let rating):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "episode_id": episodeId, "type": type, "rating": rating])
        case .updateEpfav(let token, _, let type, let rating):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "type": type, "rating": rating])
        case .destroyEpfav(let token, _):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token])
        case .createEpfavReview(let token, let episodeId, let dramaId, let type, let rating, let title, let content, let visible):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "episode_id": episodeId, "drama_id": dramaId, "type": type, "rating": rating, "title": title, "content": content, "visible": visible])
        case .updateEpfavReview(let token, _, let dramaId, let type, let rating, let title, let content, let visible):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "drama_id": dramaId, "type": type, "rating": rating, "title": title, "content": content, "visible": visible])
        case .createFavorite(let token, let dramaId, let type, let rating, let tags):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "drama_id": dramaId, "type": type, "rating": rating, "tags": tags])
        case .updateFavorite(let token, _, let type, let rating, let tags):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "type": type, "rating": rating, "tags": tags])
        case .destroyFavorite(let token, _):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token])
        case .createFavoriteReview(let token, let dramaId, let type, let rating, let tags, let title, let content, let visible):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "drama_id": dramaId, "type": type, "rating": rating, "tags": tags, "title": title, "content": content, "visible": visible])
        case .updateFavoriteReview(let token, _, let type, let rating, let tags, let title, let content, let visible):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["_token": token, "type": type, "rating": rating, "tags": tags, "title": title, "content": content, "visible": visible])
        default:
            break
        }
        
        return urlRequest
    }
    
}
