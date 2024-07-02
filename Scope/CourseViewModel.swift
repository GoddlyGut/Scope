//
//  ViewModel.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import Foundation

class CourseViewModel {
    static var shared = CourseViewModel()
    
    var courses: [Course] = [
        Course(id: UUID(), name: "English", instructor: "Steve", schedule: CourseSchedule(meetings: [
            
            DailyMeeting(day: .wednesday, startTime: "09:00", endTime: "10:30"),
            DailyMeeting(day: .tuesday, startTime: "09:00", endTime: "10:30"),
            DailyMeeting(day: .monday, startTime: "20:00", endTime: "23:59"),
        ])),
        Course(id: UUID(), name: "Math", instructor: "James", schedule: CourseSchedule(meetings: [
            DailyMeeting(day: .monday, startTime: "10:40", endTime: "12:10"),
            DailyMeeting(day: .tuesday, startTime: "03:40", endTime: "12:10"),
            DailyMeeting(day: .thursday, startTime: "10:40", endTime: "12:10")
        ])),
        Course(id: UUID(), name: "Science", instructor: "Ari", schedule: CourseSchedule(meetings: [
            DailyMeeting(day: .friday, startTime: "11:00", endTime: "12:30")
        ]))
    ]

    func currentCourse() -> Course? {
        let now = Date()
        let currentDay = DaysOfTheWeek(rawValue: Calendar.current.component(.weekday, from: now) - 1)!
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: now)
        
        for course in courses {
            for meeting in course.schedule.meetings where meeting.day == currentDay {
                if currentTime >= meeting.startTime && currentTime <= meeting.endTime {
                    return course
                }
            }
        }
        return nil
    }
    
    func coursesForToday() -> [Course] {
        let today = DaysOfTheWeek(rawValue: Calendar.current.component(.weekday, from: Date()) - 1)!
        return courses.filter { course in
            course.schedule.meetings.contains { $0.day == today }
        }
    }
}

