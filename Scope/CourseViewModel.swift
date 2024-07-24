//
//  ViewModel.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import Foundation

class CourseViewModel {
    static var shared = CourseViewModel()
    private var timer: Timer?
    var onCountdownUpdate: (() -> Void)?
    var currentCourseRemainingTime = 0.0
    var isCurrentCourseOngoing = false
    
    init() {
        startCountdownTimer()
    }
    
    var courses: [Course] = [
        Course(id: UUID(), name: "English", instructor: "Steve", schedule: CourseSchedule(meetings: [
            
            DailyMeeting(day: .wednesday, startTime: "09:00", endTime: "10:30"),
            DailyMeeting(day: .tuesday, startTime: "12:20", endTime: "15:30"),
            DailyMeeting(day: .monday, startTime: "22:59", endTime: "23:04"),
        ])),
        Course(id: UUID(), name: "Math", instructor: "James", schedule: CourseSchedule(meetings: [
            DailyMeeting(day: .wednesday, startTime: "10:40", endTime: "12:10"),
            DailyMeeting(day: .tuesday, startTime: "03:40", endTime: "12:10"),
            DailyMeeting(day: .monday, startTime: "03:40", endTime: "12:10")
        ])),
        Course(id: UUID(), name: "Science", instructor: "Ari", schedule: CourseSchedule(meetings: [
            DailyMeeting(day: .monday, startTime: "17:52", endTime: "18:55")
        ]))
    ]

    func currentCourse() -> Course? {
        let now = Date()
        let currentDay = DaysOfTheWeek(rawValue: Calendar.current.component(.weekday, from: now) - 1)!
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
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
        
        let filteredCourses = courses.filter { course in
                course.schedule.meetings.contains { $0.day == today }
            }
        
        let sortedCourses = filteredCourses.sorted { course1, course2 in
                let course1Meeting = course1.schedule.meetings.first { $0.day == today }!
                let course2Meeting = course2.schedule.meetings.first { $0.day == today }!
                
                return course1Meeting.startTime < course2Meeting.startTime
            }
            
            return sortedCourses
    }
    
    func createDate(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }
    
    
    func startCountdownTimer() {
            timer?.invalidate()  // Stops any existing timer
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        }

        @objc private func updateCountdown() {
            guard let nextEvent = findCurrentOrNextCourseEvent() else {
                currentCourseRemainingTime = 0
                onCountdownUpdate?()
                postUpdateNotification()
                return
            }

            let now = Date()
            
            var remainingTime: Double?
            
            isCurrentCourseOngoing = nextEvent.isOngoing
            
            if nextEvent.startTime.timeIntervalSinceNow < 0 {
                remainingTime = nextEvent.endTime.timeIntervalSince(now)
            }
            else {
                remainingTime = nextEvent.startTime.timeIntervalSince(now)
            }
            

            
            if remainingTime! > 0 {
                currentCourseRemainingTime = remainingTime!
            } else {
                currentCourseRemainingTime = 0.0
            }
            onCountdownUpdate?()
            
            postUpdateNotification()
            
        }
    
    private func postUpdateNotification() {
        NotificationCenter.default.post(name: .didUpdateCountdown, object: nil)
    }
    func findCurrentOrNextCourseEvent() -> (course: Course, startTime: Date, endTime: Date, isOngoing: Bool)? {
        let now = Date()
        let calendar = Calendar.current
        let currentDay = DaysOfTheWeek(rawValue: calendar.component(.weekday, from: now) - 1)!
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone.current

        func combineDateAndTime(date: Date, time: String) -> Date? {
            guard let timeDate = timeFormatter.date(from: time) else { return nil }
            let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
            return calendar.date(bySettingHour: timeComponents.hour!, minute: timeComponents.minute!, second: 0, of: date)
        }

        var closestEvent: (course: Course, startTime: Date, endTime: Date, isOngoing: Bool)?
        var shortestTimeDifference: TimeInterval = TimeInterval.greatestFiniteMagnitude

        for course in courses {
            for meeting in course.schedule.meetings where meeting.day == currentDay {
                guard let startTime = combineDateAndTime(date: Date(), time: meeting.startTime),
                      let endTime = combineDateAndTime(date: Date(), time: meeting.endTime) else {
                    continue
                }

                if now >= startTime && now <= endTime {
                    // Current ongoing course
                    return (course, startTime, endTime, isOngoing: true)
                } else if startTime > now {
                    // Next upcoming course
                    let timeDifference = startTime.timeIntervalSince(now)
                    if timeDifference < shortestTimeDifference {
                        shortestTimeDifference = timeDifference
                        closestEvent = (course, startTime, endTime, isOngoing: false)
                    }
                }
            }
        }

        return closestEvent
    }


        func formatTimeInterval(_ interval: TimeInterval) -> String {
            let hours = Int(interval) / 3600
            let minutes = Int(interval) % 3600 / 60
            let seconds = Int(interval) % 60
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        }

        deinit {
            timer?.invalidate()
        }
    
    func convertStringToTime(timeString: String) -> Date? {
        // Create a DateFormatter to parse the input time string
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")  // Use POSIX to ensure 24-hour parsing

        // Convert the input string to a Date object
        guard let date = inputFormatter.date(from: timeString) else {
            return nil  // Return nil if parsing fails
        }

        
        return date
    }

}

