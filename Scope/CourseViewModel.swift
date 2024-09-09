//
//  ViewModel.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import Foundation
import CloudKit

class CourseViewModel {
    static var shared = CourseViewModel()
    private var timer: Timer?
    var onCountdownUpdate: (() -> Void)?
    var currentCourseRemainingTime = 0.0
    var isCurrentCourseOngoing = false
    private let publicDatabase = CKContainer.default().privateCloudDatabase
    init() {
        //
        loadData()
        loadBlocks()
        loadScheduleTypes()
//        saveBlocks()
//        saveScheduleTypes()
//        saveData()
                startCountdownTimer()
        //initializeBlocks()
        //addSchoolDay()
       
        
        
    }
    
    var schoolDays: [SchoolDay] = [
        
    ]
     {
        didSet {
            saveData()
            NotificationCenter.default.post(name: .didUpdateSchoolDays, object: nil)
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
                
//                NotificationCenter.default.post(name: .didUpdateScheduleType, object: nil)
            }
        }
    
    var blocksByScheduleType: [UUID: [Block]] = [:] {
            didSet {
                //NotificationCenter.default.post(name: .didUpdateBlocks, object: nil)
                saveBlocks()
            }
        }
    
    func initializeBlocks() {
        // Assuming these are your existing schedule types with predefined blocks
        let regularDay = ScheduleType(name: "Regular Day")
        let eDay = ScheduleType(name: "eDay")
        let hDay = ScheduleType(name: "hDay")
        let delayedOpening = ScheduleType(name: "Delayed Opening")
        
        // Add these schedule types to your CourseViewModel's scheduleTypes array
        scheduleTypes = [regularDay, eDay, hDay, delayedOpening]
        
        // Assign blocks to each schedule type
        blocksByScheduleType[regularDay.id] = [
            Block(blockNumber: 1, startTime: "08:10", endTime: "09:08"),
            Block(blockNumber: 2, startTime: "09:12", endTime: "10:14"),
            Block(blockNumber: 3, startTime: "10:18", endTime: "11:16"),
            Block(blockNumber: 4, startTime: "12:09", endTime: "13:07"),
            Block(blockNumber: 5, startTime: "13:11", endTime: "14:09"),
            Block(blockNumber: 6, startTime: "14:13", endTime: "15:11")
        ]
        
        blocksByScheduleType[eDay.id] = [
            Block(blockNumber: 1, startTime: "08:30", endTime: "09:09"),
            Block(blockNumber: 2, startTime: "09:13", endTime: "09:52"),
            Block(blockNumber: 3, startTime: "10:08", endTime: "10:47"),
            Block(blockNumber: 4, startTime: "10:51", endTime: "11:30")
        ]
        
        blocksByScheduleType[hDay.id] = [
            Block(blockNumber: 1, startTime: "08:10", endTime: "08:38"),
            Block(blockNumber: 2, startTime: "08:42", endTime: "09:08"),
            Block(blockNumber: 3, startTime: "09:12", endTime: "09:38"),
            Block(blockNumber: 4, startTime: "09:42", endTime: "10:08"),
            Block(blockNumber: 5, startTime: "10:12", endTime: "10:38"),
            Block(blockNumber: 6, startTime: "10:42", endTime: "11:08")
        ]
        
        blocksByScheduleType[delayedOpening.id] = [
            Block(blockNumber: 1, startTime: "10:10", endTime: "10:48"),
            Block(blockNumber: 2, startTime: "10:52", endTime: "11:31"),
            Block(blockNumber: 3, startTime: "12:24", endTime: "13:03"),
            Block(blockNumber: 4, startTime: "13:07", endTime: "13:46")
        ]
        
        // Save these blocks for persistence
        saveBlocks()
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
            if let blockIndex = blocks.firstIndex(where: { $0.blockNumber == newBlock.blockNumber }) {
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        // Get the current time as a Date object
        let currentTime = formatter.string(from: now)
        guard let currentDateTime = formatter.date(from: currentTime) else {
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
                        // Convert block start and end times to Date objects
                        if let blockStartTime = formatter.date(from: block.startTime),
                           let blockEndTime = formatter.date(from: block.endTime) {
                            
                            if currentDateTime >= blockStartTime && currentDateTime <= blockEndTime {
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

        // Get the current schedule type for today
        guard let dayType = CourseViewModel.shared.scheduleType(on: now),
              let blocks = CourseViewModel.shared.blocksByScheduleType[dayType.id] else {
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

