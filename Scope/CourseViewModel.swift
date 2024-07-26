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
    
    var schoolDays: [SchoolDay] = [SchoolDay(date: Date(), isHoliday: false, isHalfDay: false, dayType: .regular)]
    
    // Define course schedules
    let courses: [Course] = [
        Course(id: UUID(), name: "English", instructor: "Steve", schedule: [
            CourseDaySchedule(day: .monday, scheduleType: .eDay, courseBlocks: [
                CourseBlock(courseName: "English", blockNumber: 1),
                CourseBlock(courseName: "English", blockNumber: 2)
            ]),
            CourseDaySchedule(day: .friday, scheduleType: .regular, courseBlocks: [
                CourseBlock(courseName: "English", blockNumber: 1)
            ])
        ]),
        Course(id: UUID(), name: "Math", instructor: "James", schedule: [
            CourseDaySchedule(day: .tuesday, scheduleType: .regular, courseBlocks: [
                CourseBlock(courseName: "Math", blockNumber: 1),
                CourseBlock(courseName: "Math", blockNumber: 2),
                CourseBlock(courseName: "Math", blockNumber: 3)
            ]),
            CourseDaySchedule(day: .friday, scheduleType: .regular, courseBlocks: [
                CourseBlock(courseName: "Math", blockNumber: 2)
            ])
        ]),
        Course(id: UUID(), name: "Science", instructor: "Ari", schedule: [
            CourseDaySchedule(day: .friday, scheduleType: .regular, courseBlocks: [
                CourseBlock(courseName: "Science", blockNumber: 3)
            ])
        ])
    ]

    
    
    func isSchoolRunning(on date: Date) -> Bool {
            guard let schoolDay = schoolDays.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
                return false
            }
            return !schoolDay.isHoliday
        }
        
        func isHalfDay(on date: Date) -> Bool {
            guard let schoolDay = schoolDays.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
                return false
            }
            return schoolDay.isHalfDay
        }
    
    func scheduleType(on date: Date) -> ScheduleType {
        guard let schoolDay = schoolDays.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return .regular
        }
        return schoolDay.dayType
    }
        
    func coursesForToday(_ date: Date = Date()) -> [(course: Course, block: Block, day: DaysOfTheWeek)] {
        let dayOfWeek = DaysOfTheWeek(rawValue: Calendar.current.component(.weekday, from: date) - 1)!
        
        // Check if school is running on the given date
        guard isSchoolRunning(on: date) else { return [] }

        // Get the dayType for the given date
        let dayType = self.scheduleType(on: date)

        // Collect all blocks for the given date
        var blocksForDate: [(course: Course, block: Block, day: DaysOfTheWeek)] = []

        for course in courses {
            for daySchedule in course.schedule where daySchedule.day == dayOfWeek {
                let blocks: [Block]
                switch dayType {
                case .regular:
                    blocks = isHalfDay(on: date) ? hDayBlocks : regularDayBlocks
                case .eDay:
                    blocks = eDayBlocks
                case .hDay:
                    blocks = hDayBlocks
                case .delayedOpening:
                    blocks = delayedOpeningBlocks
                }
                
                for courseBlock in daySchedule.courseBlocks {
                    if let block = blocks.first(where: { $0.blockNumber == courseBlock.blockNumber }) {
                        blocksForDate.append((course, block, daySchedule.day))
                    }
                }
            }
        }

        // Sort blocks by start time
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        blocksForDate.sort { (lhs, rhs) -> Bool in
            guard let lhsStartTime = formatter.date(from: lhs.block.startTime),
                  let rhsStartTime = formatter.date(from: rhs.block.startTime) else {
                return false
            }
            return lhsStartTime < rhsStartTime
        }

        return blocksForDate
    }


    func currentCourse(currentDate: Date = Date()) -> Course? {
        let now = currentDate
        let currentDay = DaysOfTheWeek(rawValue: Calendar.current.component(.weekday, from: now) - 1)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: now)
        
        for course in courses {
            for daySchedule in course.schedule where daySchedule.day == currentDay {
                // Determine the current schedule type (this example uses .regular for simplicity)
                let scheduleType = daySchedule.scheduleType
                
                // Get the appropriate blocks for the current schedule type
                let blocks: [Block]
                switch scheduleType {
                case .regular:
                    blocks = regularDayBlocks
                case .eDay:
                    blocks = eDayBlocks
                case .hDay:
                    blocks = hDayBlocks
                case .delayedOpening:
                    blocks = delayedOpeningBlocks
                }
                
                // Check if the current time falls within any of the blocks for this course
                for courseBlock in daySchedule.courseBlocks {
                    let block = blocks.first { $0.blockNumber == courseBlock.blockNumber }
                    
                    if let block = block {
                        if currentTime >= block.startTime && currentTime <= block.endTime {
                            return course
                        }
                    }
                }
            }
        }
        return nil
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
            guard let nextEvent = currentOrNextCourse() else {
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
    func combineDateAndTime(date: Date, time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = "\(formatter.string(from: date).prefix(10)) \(time)"
        return formatter.date(from: dateString)
    }

    func currentOrNextCourse(currentDate: Date = Date()) -> (course: Course, startTime: Date, endTime: Date, isOngoing: Bool)? {
        let now = currentDate
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: now)
        
        var closestEvent: (course: Course, startTime: Date, endTime: Date, isOngoing: Bool)?
        var shortestTimeDifference: TimeInterval = .greatestFiniteMagnitude
        
        // Check if school is running today
        guard CourseViewModel.shared.isSchoolRunning(on: now) else {
            return nil
        }

        let dayType = CourseViewModel.shared.scheduleType(on: now)
        let blocks: [Block]
        switch dayType {
        case .regular:
            blocks = CourseViewModel.shared.isHalfDay(on: now) ? hDayBlocks : regularDayBlocks
        case .eDay:
            blocks = eDayBlocks
        case .hDay:
            blocks = hDayBlocks
        case .delayedOpening:
            blocks = delayedOpeningBlocks
        }
        
        for course in courses {
            for daySchedule in course.schedule {
                if daySchedule.scheduleType == dayType {
                    for courseBlock in daySchedule.courseBlocks {
                        if let block = blocks.first(where: { $0.blockNumber == courseBlock.blockNumber }) {
                            guard let startTime = combineDateAndTime(date: now, time: block.startTime),
                                  let endTime = combineDateAndTime(date: now, time: block.endTime) else {
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

