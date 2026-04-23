import Testing
@testable import GroundsCrew

import Foundation

extension Date {
    static var startDate: Date {
        var components = DateComponents()
        components.calendar = .current
        components.year = 2024
        components.month = 4
        components.day = 23
        return components.date!
    }

    static var endDate: Date {
        var components = DateComponents()
        components.calendar = .current
        components.year = 2024
        components.month = 4
        components.day = 30
        return components.date!
    }

    static var endDateBeforeStartDate: Date {
        var components = DateComponents()
        components.calendar = .current
        components.year = 2024
        components.month = 4
        components.day = 1
        return components.date!
    }
}

@Test
func scheduleClientURLForFetchConfigurationAll() async throws {
    let client = try ScheduleClient(fetchConfiguration: .today)
    #expect(try client.url.absoluteString == "https://statsapi.mlb.com/api/v1/schedule?sportId=1")
}

@Test
func scheduleClientURLForFetchConfigurationRange() async throws {
    let client = try ScheduleClient(fetchConfiguration: .dateRange(startDate: .startDate, endDate: .endDate))
    #expect(client.url.absoluteString == "https://statsapi.mlb.com/api/v1/schedule?sportId=1&startDate=2024-04-23&endDate=2024-04-30")
}

@Test
func testScheduleClientThrowsErrorWhenEndDateIsBeforeStartDate() async throws {
    #expect(throws: ScheduleClientError.invalidConfiguration) {
        try ScheduleClient(fetchConfiguration: .dateRange(startDate: .startDate, endDate: .endDateBeforeStartDate))
    }
}

@Test
func fetchScheduleForToday() async throws {
    let client = try ScheduleClient(fetchConfiguration: .today)
    let response = await client.fetch()
    if let response {
        print(response)
    }
}

@Test
func fetchScheduleForDate() async throws {
    let date = DateComponents(calendar: .current, year: 2024, month: 3, day: 28).date!
    let client = try ScheduleClient(fetchConfiguration: .date(date: date))
    let response = await client.fetch()
    if let response {
//        print(response)
    }
}

@Test
func fetchScheduleForDateRange() async throws {
    let startDate = Date.openingDay2024
    let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!

    let client = try ScheduleClient(fetchConfiguration: .dateRange(startDate: startDate, endDate: endDate))
    let response = await client.fetch()
    if let response {
//        print(response)
        for venue in response.venues {
            print(venue)
        }

        for game in response.games {
            print(game)
        }
    }
}


@Test
func fetch2024OpeningDaySchedule() async throws {
    let openingDay = DateComponents(calendar: .current, year: 2024, month: 3, day: 28).date!

//    let client = try ScheduleClient(fetchConfiguration: .alloc(with: openingDay))


}

extension Date {
    static let openingDay2024 = DateComponents(calendar: .current, year: 2024, month: 3, day: 28).date!
    static let closingDay2024 = DateComponents(calendar: .current, year: 2024, month: 10, day: 30).date!
}

extension DateComponents {
    static func with(year: Int, month: Int, day: Int) -> DateComponents {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return dateComponents
    }

//    init(year: Int, month: Int, day: Int) {
//        let d = self.init()
//        d.year = year
//        d.month = month
//        d.day = day
//    }
}

