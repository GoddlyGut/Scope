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

enum ScheduleType {
    case regular
    case eDay
    case hDay
    case delayedOpening
}

struct Block {
    var blockNumber: Int
    var startTime: String
    var endTime: String
}

struct DaySchedule {
    var day: DaysOfTheWeek
    var scheduleType: ScheduleType
    var blocks: [Block]
}

struct CourseBlock {
    var course: Course
    var blockNumber: Int
}

struct Course: Equatable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.id == rhs.id
    }
    
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
