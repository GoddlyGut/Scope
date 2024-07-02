//
//  Model.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import Foundation

enum DaysOfTheWeek: Int {
    case sunday = 0
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

struct Course {
    var id: UUID
    var name: String
    var instructor: String
    var schedule: CourseSchedule
}

struct CourseSchedule {
    var meetings: [DailyMeeting]
}

struct DailyMeeting {
    var day: DaysOfTheWeek
    var startTime: String
    var endTime: String
}
