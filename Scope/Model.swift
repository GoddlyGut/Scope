//
//  Model.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import Foundation
import CloudKit

enum DaysOfTheWeek: Int, Codable {
    case sunday = 0
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}


struct ScheduleType: Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
    
    static let none = ScheduleType(name: "None")
}



struct SchoolDay: Codable {
    let date: Date
    let isHoliday: Bool
    let isHalfDay: Bool
    let dayType: ScheduleType
    
    init(date: Date, isHoliday: Bool = false, isHalfDay: Bool = false, dayType: ScheduleType) {
        self.date = date
        self.isHoliday = isHoliday
        self.isHalfDay = isHalfDay
        self.dayType = dayType
    }
}

struct Block: Codable {
    var blockNumber: Int
    var startTime: String
    var endTime: String
}

struct DaySchedule: Codable {
    var day: DaysOfTheWeek
    var scheduleType: ScheduleType
    var blocks: [Block]
}

struct CourseBlock: Codable {
    var courseName: String
    var blockNumber: Int
}

struct Course: Equatable, Codable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: UUID
    var name: String
    var instructor: String
    var schedule: [CourseDaySchedule]
}
struct CourseDaySchedule: Codable {
    var scheduleType: ScheduleType
    var courseBlocks: [CourseBlock]
}
//
//// Define blocks for different schedules
//let regularDayBlocks = [
//    Block(blockNumber: 1, startTime: "8:10", endTime: "9:08"),
//    Block(blockNumber: 2, startTime: "9:12", endTime: "10:14"),
//    Block(blockNumber: 3, startTime: "10:18", endTime: "11:16"),
//    Block(blockNumber: 4, startTime: "12:09", endTime: "13:07"),
//    Block(blockNumber: 5, startTime: "13:11", endTime: "14:09"),
//    Block(blockNumber: 6, startTime: "14:13", endTime: "15:11"),
//]
//
//let eDayBlocks = [
//    Block(blockNumber: 1, startTime: "8:30", endTime: "9:09"),
//    Block(blockNumber: 2, startTime: "9:13", endTime: "9:52"),
//    Block(blockNumber: 3, startTime: "10:08", endTime: "10:47"),
//    Block(blockNumber: 4, startTime: "10:51", endTime: "11:30")
//]
//
//let hDayBlocks = [
//    Block(blockNumber: 1, startTime: "8:10", endTime: "8:38"),
//    Block(blockNumber: 2, startTime: "8:42", endTime: "9:08"),
//    Block(blockNumber: 3, startTime: "9:12", endTime: "9:38"),
//    Block(blockNumber: 4, startTime: "9:42", endTime: "10:08"),
//    Block(blockNumber: 5, startTime: "10:12", endTime: "10:38"),
//    Block(blockNumber: 6, startTime: "10:42", endTime: "11:08")
//]
//
//let delayedOpeningBlocks = [
//    Block(blockNumber: 1, startTime: "10:10", endTime: "10:48"),
//    Block(blockNumber: 2, startTime: "10:52", endTime: "11:31"),
//    Block(blockNumber: 3, startTime: "12:24", endTime: "13:03"),
//    Block(blockNumber: 4, startTime: "13:07", endTime: "13:46")
//]
//
//
//
