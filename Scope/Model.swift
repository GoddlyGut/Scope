//
//  Model.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import Foundation

enum DaysOfTheWeek {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

struct Day {
    var id: UUID
    var day: DaysOfTheWeek
    var courses: [Course]
}

struct Course {
    var id: UUID
    var name: String
    var instructor: String
    var daysMeeting: [IndividualCourseSchedule]
}

struct IndividualCourseSchedule {
    var dayOfTheWeek: DaysOfTheWeek
    var beginTime: Date
    var endTime: Date
}
