//
//  ViewModel.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import Foundation
import CloudKit
import ActivityKit

class CourseViewModel {
    static var shared = CourseViewModel()
    private var timer: DispatchSourceTimer!
    var onCountdownUpdate: (() -> Void)?
    var isCurrentCourseOngoing = false
    private let publicDatabase = CKContainer.default().privateCloudDatabase
    private var dispatchTimer: DispatchSourceTimer?
    var currentActivity: Activity<CourseActivityAttributes>?
    private var lastUpdatedRemainingTime: TimeInterval?
    private var currentDisplayedCourse: Course?
    init() {
        restoreLiveActivity()
        loadData()
        loadBlocks()
        loadScheduleTypes()
//        saveBlocks()
//        saveScheduleTypes()
//        saveData()
                startCountdownTimer()
        //initializeBlocks()
        //addSchoolDay()
        NotificationManager.shared.clearAllPendingNotifications()
        scheduleNotificationsForAllCourses()
        
    }
    
    func scheduleNotificationsForAllCourses() {
        var notifications: [(courseName: String, startTime: Date)] = []

        // Loop over each school day in the future
        for schoolDay in schoolDays {
            let date = schoolDay.date ?? Date()
            
            // Get the courses for each specific day
            let dayCourses = coursesForDay(date: date)
            
            for (course, block, _) in dayCourses {
                // Calculate the start time by combining the day and block start time
                if let startTime = combineDateAndTime(date: date, time: block.startTime) {
                    notifications.append((courseName: course.name, startTime: startTime))
                    print(startTime)
                }
            }
        }
        
        
        
        // Schedule all notifications
        NotificationManager.shared.scheduleNotifications(for: notifications)
    }
    
    func coursesForDay(date: Date) -> [(course: Course, block: Block, dayType: ScheduleType)] {
        // This is essentially the same as your `coursesForToday()` but accepts any date.
        let dayOfWeek = DaysOfTheWeek(rawValue: Calendar.current.component(.weekday, from: date) - 1)!
        
        guard isSchoolRunning(on: date), let dayType = scheduleType(on: date) else { return [] }

        var blocksForDate: [(course: Course, block: Block, dayType: ScheduleType)] = []

        for course in courses {
            for daySchedule in course.schedule where daySchedule.scheduleType.id == dayType.id {
                if let blocks = blocksByScheduleType[dayType.id] {
                    for courseBlock in daySchedule.courseBlocks {
                        if let block = blocks.first(where: { $0.blockNumber == courseBlock.blockNumber }) {
                            blocksForDate.append((course, block, daySchedule.scheduleType))
                        }
                    }
                }
            }
        }

        return blocksForDate
    }


    
    var schoolDays: [SchoolDay] = [
        
    ]
     {
        didSet {
            saveData()
            
            NotificationManager.shared.clearAllPendingNotifications()
            scheduleNotificationsForAllCourses()
            //NotificationCenter.default.post(name: .didUpdateSchoolDays, object: nil)
        }
    }
    
    // Save the activity ID to UserDefaults
    func saveCurrentActivityDetails(activityID: String, startTime: Date, endTime: Date) {
        UserDefaults.standard.set(activityID, forKey: "currentActivityID")
    }

    // Retrieve the activity ID from UserDefaults
    func retrieveCurrentActivityID() -> String? {
        guard let uuidString = UserDefaults.standard.string(forKey: "currentActivityID") else { return nil }
        return uuidString
    }
    

    func retrieveCurrentActivityDetails() -> String? {
        guard let activityID = UserDefaults.standard.string(forKey: "currentActivityID") else {
            return nil
        }
        return activityID
    }



    func restoreLiveActivity() {
        // Retrieve saved activity details
        guard let details = retrieveCurrentActivityDetails(),
              let activity = Activity<CourseActivityAttributes>.activities.first(where: { $0.id == details }) else {
            return
        }

        // Assuming you can calculate the current course and remaining time based on system time
        if let nextEvent = currentOrNextCourse() {
            let remainingTime = nextEvent.endTime.timeIntervalSinceNow
            
            // Update the live activity with the calculated remaining time
            updateLiveActivity(activity: activity, courseName: nextEvent.course.name, startTime: nextEvent.startTime, endTime: nextEvent.endTime, isOngoing: nextEvent.isOngoing)
            
            // Check if there is still remaining time
            if remainingTime > 0 {
                currentActivity = activity
                print("Live Activity restored: \(activity.id)")
            } else {
                // If no time remains, end the live activity
                endLiveActivity(activity: activity)
                print("Live Activity ended: \(activity.id)")
            }
        } else {
            // No active or next course, so end the live activity
            endLiveActivity(activity: activity)
            print("Live Activity ended as no current or next course was found.")
        }
    }


    func startLiveActivity(for course: Course, startTime: Date, endTime: Date, isOngoing: Bool, showPromptToOpenApp: Bool) {
        if currentActivity != nil { return }

        // Use the system time to calculate the remaining time
        let timeRemaining = endTime.timeIntervalSinceNow

        let attributes = CourseActivityAttributes(courseName: course.name)
        let initialContentState = CourseActivityAttributes.ContentState(courseName: course.name, startTime: startTime, endTime: endTime, isOngoing: isOngoing, showPromptToOpenApp: false)

        let activityContent = ActivityContent(state: initialContentState, staleDate: nil)

        do {
            let activity = try Activity.request(attributes: attributes, content: activityContent)
            currentActivity = activity
            saveCurrentActivityDetails(activityID: activity.id, startTime: startTime, endTime: endTime)
            print("Live Activity started: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func updateLiveActivity(activity: Activity<CourseActivityAttributes>, courseName: String, startTime: Date, endTime: Date, isOngoing: Bool, showPromptToOpenApp: Bool = false) {
        let updatedContentState = CourseActivityAttributes.ContentState(courseName: courseName, startTime: startTime, endTime: endTime, isOngoing: isOngoing, showPromptToOpenApp: showPromptToOpenApp)
            
        Task {
            do {
                print("Attempting to update Live Activity...")
                try await activity.update(using: updatedContentState)
                print("Live Activity updated")
            } catch {
                print("Error updating Live Activity: \(error)")
            }
        }
    }


    func endLiveActivity(activity: Activity<CourseActivityAttributes>) {
        Task {
            await activity.end(dismissalPolicy: .immediate)
            currentActivity = nil
            clearCurrentActivityDetails()  // Clear the saved details
            print("Live Activity ended")
        }
    }

    // Clear the activity ID and details from UserDefaults
    func clearCurrentActivityDetails() {
        UserDefaults.standard.removeObject(forKey: "currentActivityID")
    }
    
    @objc private func updateCountdown() {
        let now = Date()
        
        // Check if there's an ongoing or upcoming course
        guard let nextEvent = currentOrNextCourse() else {
            isCurrentCourseOngoing = false
            postUpdateNotification()
            if let activity = currentActivity {
                endLiveActivity(activity: activity)
            }
            return
        }

        // Calculate remaining time for the ongoing or upcoming course
        let remainingTime: TimeInterval
        if now >= nextEvent.startTime && now <= nextEvent.endTime {
            // Course is currently ongoing
            isCurrentCourseOngoing = true
            remainingTime = nextEvent.endTime.timeIntervalSince(now)
        } else {
            // Course is upcoming
            isCurrentCourseOngoing = false
            remainingTime = nextEvent.startTime.timeIntervalSince(now)
        }
        if let currentActivity = currentActivity {
            if currentActivity.content.state.isOngoing != nextEvent.isOngoing {
                updateLiveActivity(activity: currentActivity, courseName: nextEvent.course.name, startTime: nextEvent.startTime, endTime: nextEvent.endTime, isOngoing: nextEvent.isOngoing)
                currentDisplayedCourse = nextEvent.course
            }
        }


        
        if nextEvent.isOngoing {
            if remainingTime > 0 {
                // Course is ongoing
                // Start or update Live Activity
                if currentActivity == nil {
                    startLiveActivity(for: nextEvent.course, startTime: nextEvent.startTime, endTime: nextEvent.endTime, isOngoing: nextEvent.isOngoing, showPromptToOpenApp: false)
                    currentDisplayedCourse = nextEvent.course // Update the tracked course
                } else if currentDisplayedCourse != nextEvent.course {
                    // Update live activity if it's not already showing this course
                    updateLiveActivity(activity: currentActivity!, courseName: nextEvent.course.name, startTime: nextEvent.startTime, endTime: nextEvent.endTime, isOngoing: nextEvent.isOngoing)
                    currentDisplayedCourse = nextEvent.course // Update the tracked course
                }
                onCountdownUpdate?()
            } else {
                // The current course has ended, transition to the next course
                if let nextUpcomingEvent = nextCourse() {
                    // Update the live activity for the next course if it's different
                    if currentActivity?.content.state.courseName != nextEvent.course.name {
                        updateLiveActivity(activity: currentActivity!, courseName: nextUpcomingEvent.course.name, startTime: nextUpcomingEvent.startTime, endTime: nextUpcomingEvent.endTime, isOngoing: nextUpcomingEvent.isOngoing)
                        currentDisplayedCourse = nextUpcomingEvent.course // Update the tracked course
                    }
                    else {
                        if let activity = currentActivity {
                            endLiveActivity(activity: activity)
                        }
                    }
                }
                else {
                    if let activity = currentActivity {
                        endLiveActivity(activity: activity)
                    }
                }
            }
        } else {
            // Course is upcoming
            if remainingTime >= 1 {
                // Start Live Activity if it hasn't been started yet
                if currentActivity == nil {
                    startLiveActivity(for: nextEvent.course, startTime: nextEvent.startTime, endTime: nextEvent.endTime, isOngoing: false, showPromptToOpenApp: false)
                    currentDisplayedCourse = nextEvent.course // Update the tracked course
                } else if currentDisplayedCourse != nextEvent.course {
                    // Update live activity for the upcoming course if it's different
                    updateLiveActivity(activity: currentActivity!, courseName: nextEvent.course.name, startTime: nextEvent.startTime, endTime: nextEvent.endTime, isOngoing: nextEvent.isOngoing)
                    currentDisplayedCourse = nextEvent.course // Update the tracked course
                }
                onCountdownUpdate?()
            } else {
                // Transition to the course being ongoing when the time arrives
                //if now >= nextEvent.startTime {
                    isCurrentCourseOngoing = true
                    guard let upcomingCourse = nextCourse() else {
                        return
                    }
                    // Immediately handle the transition to ongoing
                    // Update the live activity for the now ongoing course
                    if currentActivity == nil {
                        startLiveActivity(for: nextEvent.course, startTime: nextEvent.startTime, endTime: nextEvent.endTime, isOngoing: nextEvent.isOngoing, showPromptToOpenApp: false)
                        currentDisplayedCourse = nextEvent.course // Update the tracked course
                    } else if nextEvent.isOngoing == false {
                        // Update live activity for the ongoing course if it's different
                        updateLiveActivity(activity: currentActivity!, courseName: upcomingCourse.course.name, startTime: nextEvent.startTime, endTime: upcomingCourse.endTime, isOngoing: true)
                        currentDisplayedCourse = upcomingCourse.course // Update the tracked course
                    }
                //}
            }
        }

        postUpdateNotification()
    }

    

    func checkAndUpdateCourseStatus() {
        print("FETCH!")
        let now = Date()
        
        // Get the current or next course
        guard let nextEvent = currentOrNextCourse() else {
            if let currentActivity = currentActivity {
                endLiveActivity(activity: currentActivity)
            }
            
            return
        }
        if let currentActivity = currentActivity {
            if now >= nextEvent.endTime {
                // The course has ended, update accordingly
                if let currentDisplayedCourse = currentDisplayedCourse {
                    updateLiveActivity(activity: currentActivity, courseName: nextEvent.course.name, startTime: nextEvent.startTime, endTime: nextEvent.endTime, isOngoing: true, showPromptToOpenApp: true)
                }
                
            } else if now >= nextEvent.startTime && !currentActivity.content.state.isOngoing {
                updateLiveActivity(activity: currentActivity, courseName: currentActivity.content.state.courseName, startTime: currentActivity.content.state.startTime, endTime: currentActivity.content.state.endTime, isOngoing: currentActivity.content.state.isOngoing, showPromptToOpenApp: true)
            }
        }
        
    }





    
    func scheduleType(on date: Date) -> ScheduleType? {
        // 1. Check if there's a specific schedule for the date
        let specificDay = schoolDays.first(where: { $0.date != nil && Calendar.current.isDate($0.date!, inSameDayAs: date) })
        let specificSchedule = specificDay?.dayType

        if let specificSchedule = specificSchedule {
            return specificSchedule
        }
        // 2. If no specific schedule, get the recurring schedule based on the day of the week
        let dayOfWeek = DaysOfTheWeek(rawValue: Calendar.current.component(.weekday, from: date) - 1)!
        let recurringDay = schoolDays.first(where: { $0.dayOfWeek == dayOfWeek && $0.date == nil })
        let recurringSchedule = recurringDay?.dayType

        // 3. Return both the specific schedule and recurring schedule
        return (recurringSchedule)
    }

    func reccuringScheduleType(on date: Date) -> ScheduleType? {
        let specificDay = schoolDays.first(where: { $0.date != nil && Calendar.current.isDate($0.date!, inSameDayAs: date) })
        let specificSchedule = specificDay?.dayType

        // 2. If no specific schedule, get the recurring schedule based on the day of the week
        let dayOfWeek = DaysOfTheWeek(rawValue: Calendar.current.component(.weekday, from: date) - 1)!
        let recurringDay = schoolDays.first(where: { $0.dayOfWeek == dayOfWeek && $0.date == nil })
        let recurringSchedule = recurringDay?.dayType

        // 3. Return both the specific schedule and recurring schedule
        return recurringSchedule
    }


        
        // Add or update a specific date with a schedule type
        func setScheduleType(for date: Date, scheduleType: ScheduleType) {
            if let index = schoolDays.firstIndex(where: { Calendar.current.isDate($0.date ?? Date.distantPast, inSameDayAs: date) }) {
                schoolDays[index].dayType = scheduleType
            } else {
                let schoolDay = SchoolDay(date: date, dayType: scheduleType)
                schoolDays.append(schoolDay)
            }
            NotificationCenter.default.post(name: .didAddSchoolDays, object: nil)
        }
        
        // Assign schedule type to recurring weekly days
        func assignScheduleToRecurringDay(_ scheduleType: ScheduleType, for day: DaysOfTheWeek) {
            if let index = schoolDays.firstIndex(where: { $0.dayOfWeek == day }) {
                schoolDays[index].dayType = scheduleType
            } else {
                let schoolDay = SchoolDay(dayType: scheduleType, dayOfWeek: day)
                schoolDays.append(schoolDay)
            }
            NotificationCenter.default.post(name: .didAddSchoolDays, object: nil)
        }
    
    
//    func addSchoolDay() {
//        
//        //let regularDayType = ScheduleType(name: "eDay")
//        let schoolDay = SchoolDay(date: Date(), isHoliday: false, isHalfDay: false, dayType: scheduleTypes.first(where: { $0.name == "Regular Day" }) ?? ScheduleType(name: "Regular Day"))
//        
//        schoolDays.append(schoolDay)
//    }
    
    var scheduleTypes: [ScheduleType] = [] {
        didSet {
            saveScheduleTypes()

            NotificationManager.shared.clearAllPendingNotifications()
            scheduleNotificationsForAllCourses()
            
            // Ensure that currentActivity is not nil
            if let activity = currentActivity {
                // Calculate remaining time based on system time and the course's end time
                if let nextEvent = currentOrNextCourse() {
                    updateLiveActivity(activity: activity, courseName: nextEvent.course.name, startTime: nextEvent.startTime, endTime: nextEvent.endTime, isOngoing: nextEvent.isOngoing)
                }
            }

            // Optionally post a notification if needed
            // NotificationCenter.default.post(name: .didUpdateScheduleType, object: nil)
        }
    }

    
    var blocksByScheduleType: [UUID: [Block]] = [:] {
            didSet {
                //NotificationCenter.default.post(name: .didUpdateBlocks, object: nil)
                saveBlocks()
                
                NotificationManager.shared.clearAllPendingNotifications()
                scheduleNotificationsForAllCourses()
                
                if let activity = currentActivity {
                    // Calculate remaining time based on system time and the course's end time
                    if let nextEvent = currentOrNextCourse() {
                        updateLiveActivity(activity: activity, courseName: nextEvent.course.name, startTime: nextEvent.startTime, endTime: nextEvent.endTime, isOngoing: nextEvent.isOngoing)
                    }
                }
            }
        }
    
    
    
    func createScheduleType(name: String) -> ScheduleType {
            let newScheduleType = ScheduleType(name: name)
            scheduleTypes.append(newScheduleType)
        return newScheduleType
        }
        
        func updateScheduleType(id: UUID, newName: String) {
            if let index = scheduleTypes.firstIndex(where: { $0.id == id }) {
                scheduleTypes[index].name = newName
            }
        }
        
    func deleteScheduleType(id: UUID) {
        // Remove the schedule type
        scheduleTypes.removeAll { $0.id == id }
        blocksByScheduleType[id] = nil
        
        var courseList = courses
        
        
        // Iterate over all courses and remove the schedule entry that uses the deleted schedule type
        for courseIndex in courseList.indices {
            courseList[courseIndex].schedule.removeAll { $0.scheduleType.id == id }
        }
        
        courses = courseList
        
        schoolDays.removeAll { $0.dayType.id == id }
    }

        
        // Methods to manage blocks by schedule type
        func addBlock(to scheduleType: ScheduleType, block: Block) {
            if blocksByScheduleType[scheduleType.id] == nil {
                blocksByScheduleType[scheduleType.id] = []
            }
            blocksByScheduleType[scheduleType.id]?.append(block)
        }
        
    func updateBlock(in scheduleType: ScheduleType, with newBlock: Block) {
        // Retrieve the blocks array for the schedule type
        if var blocks = blocksByScheduleType[scheduleType.id] {
            // Find the index of the block that matches the block number
            if let blockIndex = blocks.firstIndex(where: { $0.id == newBlock.id }) {
                // Update the block at the found index
                blocks[blockIndex] = newBlock
            }
            // Assign the modified array back to the dictionary
            blocksByScheduleType[scheduleType.id] = blocks
        }
    }

        
    func deleteBlock(from scheduleType: ScheduleType, at index: Int) {
        // Remove the block from the specified schedule type
        blocksByScheduleType[scheduleType.id]?.remove(at: index)
        
        var courseList = courses
        
        // Iterate over all courses and their schedules to update the schedule type
        for courseIndex in courseList.indices {
            // Use `enumerated()` to safely remove items from the array while iterating
            courseList[courseIndex].schedule.enumerated().forEach { dayScheduleIndex, daySchedule in
                if daySchedule.scheduleType.id == scheduleType.id {
                    // Remove the schedule block from the course
                    courseList[courseIndex].schedule.remove(at: dayScheduleIndex)
                }
            }
        }
        
        courses = courseList

        
        
    }

        
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    func getFileURL(for fileName: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(fileName)
    }

    func saveScheduleTypes() {
        let fileURL = getFileURL(for: "scheduleTypes.json")
        
        do {
            let data = try JSONEncoder().encode(scheduleTypes)
            try data.write(to: fileURL)
            print("Successfully saved schedule types to \(fileURL)")
        } catch {
            print("Failed to save schedule types: \(error)")
        }
    }

    func loadScheduleTypes() {
        let fileURL = getFileURL(for: "scheduleTypes.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            scheduleTypes = try JSONDecoder().decode([ScheduleType].self, from: data)
            print("Successfully loaded schedule types from \(fileURL)")
        } catch {
            print("Failed to load schedule types: \(error)")
        }
    }

        
    func saveBlocks() {
        let fileURL = getFileURL(for: "blocksByScheduleType.json")
        
        do {
            let data = try JSONEncoder().encode(blocksByScheduleType)
            try data.write(to: fileURL)
            print("Successfully saved blocks to \(fileURL)")
        } catch {
            print("Failed to save blocks: \(error)")
        }
    }

    func loadBlocks() {
        let fileURL = getFileURL(for: "blocksByScheduleType.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            blocksByScheduleType = try JSONDecoder().decode([UUID: [Block]].self, from: data)
            print("Successfully loaded blocks from \(fileURL)")
        } catch {
            print("Failed to load blocks: \(error)")
        }
    }

    
    func saveData() {
        let coursesFileURL = getFileURL(for: "courses.json")
        let schoolDaysFileURL = getFileURL(for: "schoolDays.json")
        
        do {
            let coursesData = try JSONEncoder().encode(courses)
            let schoolDaysData = try JSONEncoder().encode(schoolDays)
            
            try coursesData.write(to: coursesFileURL)
            try schoolDaysData.write(to: schoolDaysFileURL)
            print("Successfully saved data to files")
            
        } catch {
            print("Failed to save data: \(error)")
        }
    }

    func loadData() {
        let coursesFileURL = getFileURL(for: "courses.json")
        let schoolDaysFileURL = getFileURL(for: "schoolDays.json")
        
        do {
            let coursesData = try Data(contentsOf: coursesFileURL)
            let schoolDaysData = try Data(contentsOf: schoolDaysFileURL)
            
            courses = try JSONDecoder().decode([Course].self, from: coursesData)
            schoolDays = try JSONDecoder().decode([SchoolDay].self, from: schoolDaysData)
            print("Successfully loaded data from files")
            
        } catch {
            print("Failed to load data: \(error)")
        }
    }

    var courses: [Course] = [] {
        didSet {
            NotificationCenter.default.post(name: .didUpdateCourseList, object: nil)
            saveData()
            
            NotificationManager.shared.clearAllPendingNotifications()
            scheduleNotificationsForAllCourses()
            
            if let activity = currentActivity {
                // Calculate remaining time based on system time and the course's end time
                if let nextEvent = currentOrNextCourse() {
                    
                    updateLiveActivity(activity: activity, courseName: nextEvent.course.name, startTime: nextEvent.startTime, endTime: nextEvent.endTime, isOngoing: nextEvent.isOngoing)
                }
            }
        }
    }

    
    
    
    func isSchoolRunning(on date: Date) -> Bool {
        // Check for a specific schedule on the exact date first
        if let schoolDay = schoolDays.first(where: { Calendar.current.isDate($0.date ?? Date.distantPast, inSameDayAs: date) }) {
            // If it's a specific date and it's marked as a holiday, return false
            return !schoolDay.isHoliday
        }
        
        // No specific date found, so check for recurring weekly days
        let dayOfWeek = DaysOfTheWeek(rawValue: Calendar.current.component(.weekday, from: date) - 1)!
        if let schoolDay = schoolDays.first(where: { $0.dayOfWeek == dayOfWeek }) {
            // If it's a recurring day and it's marked as a holiday, return false
            return !schoolDay.isHoliday
        }
        
        // If no match found, assume school is not running
        return false
    }

        
//        func isHalfDay(on date: Date) -> Bool {
//            guard let schoolDay = schoolDays.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
//                return false
//            }
//            return schoolDay.isHalfDay
//        }

        
    func coursesForToday(_ date: Date = Date()) -> [(course: Course, block: Block, dayType: ScheduleType)] {
        let dayOfWeek = DaysOfTheWeek(rawValue: Calendar.current.component(.weekday, from: date) - 1)!
        
        // Check if school is running on the given date
        guard isSchoolRunning(on: date) else { return [] }
        
        // Get the dayType for the given date
        guard let dayType = self.scheduleType(on: date) else { return [] }

        // Collect all blocks for the given date
        var blocksForDate: [(course: Course, block: Block, dayType: ScheduleType)] = []
        
        for course in courses {
            for daySchedule in course.schedule where daySchedule.scheduleType.id == dayType.id {
                if let blocks = blocksByScheduleType[dayType.id] {
                    for courseBlock in daySchedule.courseBlocks {
                        if let block = blocks.first(where: { $0.blockNumber == courseBlock.blockNumber }) {
                            blocksForDate.append((course, block, daySchedule.scheduleType))
                        }
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


    func currentCourse(currentDate: Date = Date()) -> (course: Course, block: Block)? {
        let now = currentDate
        
        // Use a more precise time format including seconds
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        // Get the current time as a Date object
        let currentTimeString = formatter.string(from: now)
        guard let currentDateTime = formatter.date(from: currentTimeString) else {
            print("Error converting current time to Date object")
            return nil
        }
        
        // Determine the schedule type for the current date
        guard let currentScheduleType = scheduleType(on: currentDate) else {
            return nil
        }
        
        // Get the blocks associated with the current schedule type
        guard let blocks = blocksByScheduleType[currentScheduleType.id] else {
            return nil
        }
        
        for course in courses {
            for daySchedule in course.schedule where daySchedule.scheduleType.id == currentScheduleType.id {
                // Check if the current time falls within any of the blocks for this course
                for courseBlock in daySchedule.courseBlocks {
                    if let block = blocks.first(where: { $0.blockNumber == courseBlock.blockNumber }) {
                        // Convert block start and end times to Date objects (with seconds)
                        if let blockStartTime = formatter.date(from: "\(block.startTime):00"),
                           let blockEndTime = formatter.date(from: "\(block.endTime):00") {
                            
                            // Ensure current time is strictly within block start and end time
                            if currentDateTime >= blockStartTime && currentDateTime < blockEndTime {
                                return (course, block)
                            }
                        } else {
                            print("Error converting block start or end time to Date object")
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
        if timer != nil {
            timer.cancel()
        }
        
        
        let now = Date()
        let nextSecond = now.timeIntervalSince1970.rounded(.down) + 1
        let intervalToWait = nextSecond - now.timeIntervalSince1970
        
        self.timer = DispatchSource.makeTimerSource(flags: .strict, queue: DispatchQueue.global(qos: .userInteractive))
        self.timer.schedule(wallDeadline: .now() + intervalToWait, repeating: 1.0, leeway: .nanoseconds(0))
        self.timer.setEventHandler(qos: .userInteractive, flags: .enforceQoS) {
            DispatchQueue.main.async {
                self.updateCountdown()
            }
        }
        self.timer.resume()
        
       
    }
    
    func nextCourse(currentDate: Date = Date()) -> (course: Course, startTime: Date, endTime: Date, isOngoing: Bool)? {
        let now = currentDate
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: now)
        
        var closestEvent: (course: Course, startTime: Date, endTime: Date, isOngoing: Bool)?
        var shortestTimeDifference: TimeInterval = .greatestFiniteMagnitude
        
        // Check if school is running today
        guard isSchoolRunning(on: now) else {
            return nil
        }

        // Get the current schedule type for today
        guard let dayType = scheduleType(on: now),
              let blocks = blocksByScheduleType[dayType.id] else {
            return nil
        }
        
        for course in courses {
            for daySchedule in course.schedule where daySchedule.scheduleType.id == dayType.id {
                for courseBlock in daySchedule.courseBlocks {
                    if let block = blocks.first(where: { $0.blockNumber == courseBlock.blockNumber }) {
                        guard let startTime = combineDateAndTime(date: now, time: block.startTime),
                              let endTime = combineDateAndTime(date: now, time: block.endTime) else {
                            continue
                        }
                        
                        if startTime > now {
                            // Upcoming course
                            let timeDifference = startTime.timeIntervalSince(now)
                            if timeDifference < shortestTimeDifference {
                                shortestTimeDifference = timeDifference
                                closestEvent = (course, startTime, endTime, isOngoing: false)
                            }
                        } else if now >= startTime && now <= endTime {
                            // Current ongoing course, but check if there's a closer upcoming course
                            let timeDifference = endTime.timeIntervalSince(now)
                            if timeDifference < shortestTimeDifference {
                                shortestTimeDifference = timeDifference
                                closestEvent = (course, startTime, endTime, isOngoing: true)
                            }
                        }
                    }
                }
            }
        }
        
        return closestEvent
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
        guard isSchoolRunning(on: now) else {
            return nil
        }

        // Get the current schedule type for today
        guard let dayType = scheduleType(on: now),
              let blocks = blocksByScheduleType[dayType.id] else {
            return nil
        }
        
        for course in courses {
            for daySchedule in course.schedule where daySchedule.scheduleType.id == dayType.id {
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
        
        return closestEvent
    }






        func formatTimeInterval(_ interval: TimeInterval) -> String {
            let hours = Int(interval) / 3600
            let minutes = Int(interval) % 3600 / 60
            let seconds = Int(interval) % 60
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        }

        deinit {
           
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

    func deleteAllData() {
        // Delete all courses, schedule types, blocks, and school days
        courses.removeAll()
        scheduleTypes.removeAll()
        blocksByScheduleType.removeAll()
        schoolDays.removeAll()
        
        // Save the changes
        saveData()
        saveScheduleTypes()
        saveBlocks()
        
        print("All data deleted")
    }

    func deleteCurrentSchedule() {
        // Assuming you want to delete only the schoolDays (which represent schedules)
        schoolDays.removeAll()
        
        // Save the changes
        saveData()
        
        print("Current schedule deleted")
    }

    func deleteAllScheduleTypes() {
        // Remove all schedule types and associated blocks
        for schedule in scheduleTypes {
            deleteScheduleType(id: schedule.id)
        }
        
        
        print("All schedule types deleted")
    }

    func deleteAllCourses() {
        // Remove all courses
        courses.removeAll()
        
        // Save the changes
        saveData()
        
        print("All courses deleted")
    }

}

