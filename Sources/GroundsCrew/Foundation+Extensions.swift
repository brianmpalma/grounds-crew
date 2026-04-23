import Foundation

extension URLResponse {
    var isOK: Bool {
        (self as? HTTPURLResponse)?.statusCode == 200
    }
}

extension URLComponents {
    static var schedule: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "statsapi.mlb.com"
        components.path = "/api/v1/schedule"
        return components
    }

    static func schedule(queryItems: [URLQueryItem]) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "statsapi.mlb.com"
        components.path = "/api/v1/schedule"
        components.queryItems = queryItems
        return components
    }
}

