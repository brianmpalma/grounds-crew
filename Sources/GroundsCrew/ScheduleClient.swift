import Foundation

public enum ScheduleFetchConfiguration {
    case today
    case date(date: Date)
    case dateRange(startDate: Date, endDate: Date)

    var queryItems: [URLQueryItem] {
        switch self {
        case .today:
            return [
                URLQueryItem(name: "sportId", value: 1.description)
            ]

        case .date(let date):
            return [
                URLQueryItem(name: "sportId", value: 1.description),
                URLQueryItem(name: "date", date: date)
            ]

        case .dateRange(let startDate, let endDate):
            return [
                URLQueryItem(name: "sportId", value: 1.description),
                URLQueryItem(name: "startDate", date: startDate),
                URLQueryItem(name: "endDate", date: endDate),
            ]
        }
    }

    var url: URL {
        URLComponents.schedule(queryItems: queryItems).url!
    }
}

public enum ScheduleClientError: Error {
    case invalidConfiguration
}

public class ScheduleClient {
    private let session: URLSession
    private let fetchConfiguration: ScheduleFetchConfiguration

    var url: URL {
        fetchConfiguration.url
    }

    public init(session: URLSession = .shared, fetchConfiguration: ScheduleFetchConfiguration) throws {
        if case .dateRange(let startDate, let endDate) = fetchConfiguration, endDate < startDate {
            throw ScheduleClientError.invalidConfiguration
        }

        self.session = session
        self.fetchConfiguration = fetchConfiguration
    }

    public func fetch() async -> Schedule.Response? {
        do {
            let (data, response) = try await URLSession.shared.data(from: fetchConfiguration.url)
            guard response.isOK, let jsonString = String(data: data, encoding: .utf8) else { return nil }

            print(jsonString)

            let schedule = try JSONDecoder().decode(Schedule.Response.self, from: data)
            return schedule
        } catch DecodingError.dataCorrupted(let context) {
            print(context.debugDescription)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("\(key.stringValue) was not found, \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            print("\(type) was expected, \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            print("no value was found for \(type), \(context.debugDescription)")
        } catch {
            print("I know not this error")
        }
        return nil
    }
}

fileprivate extension ScheduleClient {
    static var baseURLComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "statsapi.mlb.com"
        components.path = "/api/v1/schedule"
        return components
    }
}

public extension URLQueryItem {
    init(name: String, date: Date) {
        self.init(name: name, value: date.ISO8601Format(
            .iso8601
            .year()
            .month()
            .day()
            .dateSeparator(.dash)))
    }
}
