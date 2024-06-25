//
//  ViewModel.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import Foundation

class CourseViewModel {
    private let courseTwo = Course(id: UUID(), name: "English", instructor: "Steve", daysMeeting: [IndividualCourseSchedule(dayOfTheWeek: Date().dayOfTheWeek, beginTime: Date().adding(hours: -1) ?? Date(), endTime: Date().adding(hours: 4) ?? Date())])
    private let courseOne = Course(id: UUID(), name: "Math", instructor: "James", daysMeeting: [IndividualCourseSchedule(dayOfTheWeek: Date().dayOfTheWeek, beginTime: Date().adding(hours: -5) ?? Date(), endTime: Date().adding(hours: -2) ?? Date())])
    private let courseThree = Course(id: UUID(), name: "Science", instructor: "Ari", daysMeeting: [IndividualCourseSchedule(dayOfTheWeek: Date().dayOfTheWeek, beginTime: Date().adding(hours: 5) ?? Date(), endTime: Date().adding(hours: 7) ?? Date())])
    var day: Day = Day(id: UUID(), day: Date().dayOfTheWeek, courses: [])
    
    static var shared: CourseViewModel = CourseViewModel()
    
    init() {
        day.courses.append(courseTwo)
        day.courses.append(courseThree)
        day.courses.append(courseOne)
    }
    
    func sortedCourses() -> [Course] {
        return day.courses.sorted { $0.daysMeeting.first?.beginTime ?? Date() < $1.daysMeeting.first?.beginTime ?? Date() }
    }
}
