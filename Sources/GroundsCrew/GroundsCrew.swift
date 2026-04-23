import Foundation

public struct Schedule: Codable {
    public struct Response: Codable {
        public let copyright: String
        public let totalItems: Int
        public let totalGames: Int
        public let totalGamesInProgress: Int

        public let dates: [DateInfo]

        public struct DateInfo: Codable {
            public let date: String
            public let totalItems: Int
            public let totalGames: Int
            public let totalGamesInProgress: Int

            public let games: [DateInfo.Game]

            public struct Game: Codable, Identifiable {
                public var id: String { gameGuid }

                public let gamePk: Int
                public let gameGuid: String
                public let link: String
                public let gameType: String
                public let season: String
                public let gameDate: String // date
                public let officialDate: String // 8701
                public let status: DateInfo.Game.Status
                public let teams: DateInfo.Game.Teams
                public let venue: DateInfo.Game.Venue
                public let content: DateInfo.Game.Content
                public let gameNumber: Int
                public let publicFacing: Bool
                public let doubleHeader: String
                public let gamedayType: String
                public let tiebreaker: String
                public let calendarEventID: String
                public let seasonDisplay: String
                public let dayNight: String
                public let scheduledInnings: Int
                public let reverseHomeAwayStatus: Bool
                public let inningBreakLength: Int
                public let gamesInSeries: Int!
                public let seriesGameNumber: Int!
                public let seriesDescription: String
                public let recordSource: String
                public let ifNecessary: String
                public let ifNecessaryDescription: String
            }
        }
    }
}

public extension Schedule.Response {

    public var venues: [Schedule.Response.DateInfo.Game.Venue] {
        var venues: [Schedule.Response.DateInfo.Game.Venue] = []

        for date in dates {
            for game in date.games {
                venues.append(game.venue)
            }
        }

        return venues
    }

//    var games: [Schedule.Response.DateInfo.Game] {
    public var games: [DateInfo.Game] {
//        var games: [Schedule.Response.DateInfo.Game] = []
        var games: [Schedule.Response.DateInfo.Game] = []

        for date in dates {
            for game in date.games {
                games.append(game)
            }
        }

        return games
    }
}

public extension Schedule.Response.DateInfo.Game {
    public struct Status: Codable {
        public let abstractGameState: String
        public let codedGameState: String
        public let detailedState: String
        public let statusCode: String
        public let startTimeTBD: Bool
        public let abstractGameCode: String
    }

    public struct Venue: Codable, Identifiable {
        public let id: Int
        public let name: String
        public let link: String
    }

    public struct Content: Codable {
        public let link: String
    }

    public struct Teams: Codable {
        public let away: Teams.TeamInfo
        public let home: Teams.TeamInfo

        public struct TeamInfo: Codable {
            public let leagueRecord: TeamInfo.LeagueRecord
            public let score: Int?
            public let splitSquad: Bool
            public let seriesNumber: Int?
            public let isWinner: Bool?

            public let team: TeamInfo.Team

            public struct LeagueRecord: Codable {
                public let wins: Int
                public let losses: Int
                public let pct: String
            }

            public struct Team: Codable {
                public let id: Int
                public let name: String
                public let link: String
            }
        }
    }
}

import SwiftUI

// For Views

public enum WinningTeam {
    case away
    case home
    case tied
    case unknown

    public init(homeScore: Int, awayScore: Int) {
        if homeScore == awayScore {
            self = .tied
        } else if homeScore > awayScore {
            self = .home
        } else if homeScore < awayScore {
            self = .away
        } else {
            self = .unknown
        }
    }
}

public extension Schedule.Response.DateInfo.Game {

    // The Tampa Bay Rays are tied with the Boston Red Sox
    // The Rays are tied with the Red Sox, 2-2 in the 9th.
    // The Phillies are beating the Mets 15-3 in the 8th.
    // The Phillies beat the Braves 5-2 at Citizens Bank Park

    public var isTieGame: Bool {
        teams.home.score == teams.away.score
    }

    public var isGameOver: Bool {
        status.codedGameState == "F"
    }

    public var gameDescription: String {
        if isGameOver {
            if isTieGame {
                return "The \(teams.away.team.name) tied the \(teams.home.team.name), \(teams.away.score)-\(teams.home.score)"
            }

            if isHomeTeamWinning {
                return "The \(teams.home.team.name) beat the \(teams.away.team.name), \(teams.home.score)-\(teams.away.score)"
            }

            return "The \(teams.away.team.name) beat the \(teams.home.team.name), \(teams.away.score)-\(teams.home.score)"
        }

        if isTieGame {
            return "The \(teams.away.team.name) are tied with the \(teams.home.team.name), \(teams.away.score)-\(teams.home.score)"
        }

        if isHomeTeamWinning {
            return "The \(teams.home.team.name) are beating the \(teams.away.team.name), \(teams.home.score)-\(teams.away.score)"
        } else {
            return "The \(teams.away.team.name) are beating the \(teams.home.team.name), \(teams.away.score)-\(teams.home.score)"
        }
    }

    private var didHomeTeamWin: Bool {
        guard status.codedGameState == "F" else { return false }
        return false
    }

    private var isHomeTeamWinning: Bool {
        return true
//        teams.home.score > teams.away.score
    }

    private var winningTeam: WinningTeam {
        guard let homeScore = teams.home.score,
                let awayScore = teams.away.score else {
            return .unknown
        }

        return WinningTeam(homeScore: homeScore, awayScore: awayScore)
    }

    // Away team beat the home team
    // Away team tied the home team (Final, ST)
    // Away team is tied with the home team
    // Away team lost to the home team
    // Away team is losing to the home team (home team is winning)

    // The Phillies are beating the Mets 15-2 at Citi Field
    // The Phillies beat the Braves 5-3 at Citizens Banks Park
    // The Phillies are tied with the Blue Jays, 3-3 at Baycare Ballpark
    // The Phillies tied with the Blue Jays, 5-5 at Baycare Ballpark
    // The Phillies are losing to the Tigers, 3-2
    // The Phillies lost to the Red Sox, 4-2

}

public extension Schedule.Response.DateInfo.Game.Teams.TeamInfo {
    public var subtitle: String {
        return "(\(leagueRecord.wins) - \(leagueRecord.losses), \(leagueRecord.pct))"
    }
}

//public struct GameFeed {
//    public let copyright: String
//    public let gamePK: Int
//    public let link: String
//    public let metaData: MetaData
//}

//public extension GameFeed {
//
//    public struct MetaData {
//        let wait: Int
//        let timeStamp: String
//        let gameEvents: [String]
//        let locicalEvents: [String]
//    }
//
//    public struct GameData {
//        let game: Game
//
//        let datetime: DateTime
//    }
//}

//public struct Game: Codable {
//    let pk: Int
//    let type: String
//    let doubleHeader: String
//    let id: String
//    let gamedayType: String
//    let tiebreaker: String
//    let gameNumber: Int
//    let calendarEventID: String
//    let season: String
//    let seasonDisplay: String
//}
//
//public struct DateTime: Codable {
//    let dateTime: String
//    let originalDate: String
//    let officialDate: String
//    let dayNight: String
//    let time: String
//    let ampm: String
//}
//
//public struct Status: Codable {
//    let abstractGameState: String
//    let codedGameState: String
//    let detailedState: String
//    let statusCode: String
//    let startTimeTBD: Bool
//    let abstractGameCode: String
//}
//
//
//
//public struct MetaData {
//    let wait: Int
//
//    let timeStamp: String
//
//    let gameEvents: [String]
//
//    let locicalEvents: [String]
//}
//
//public struct GameData {
//
//}
//
//public extension GameData {
//    public struct Game: Codable {
//        let pk: Int
//        let type: String
//        let doubleHeader: String
//        let id: String
//        let gamedayType: String
//        let tiebreaker: String
//        let gameNumber: Int
//        let calendarEventID: String
//        let season: String
//        let seasonDisplay: String
//    }
//}
//
//
////"gameData": {
////  "game": {
////    "pk": 746238,
////    "type": "R",
////    "doubleHeader": "N",
////    "id": "2024/05/01/phimlb-anamlb-1",
////    "gamedayType": "P",
////    "tiebreaker": "N",
////    "gameNumber": 1,
////    "calendarEventID": "14-746238-2024-05-01",
////    "season": "2024",
////    "seasonDisplay": "2024"
////  },
