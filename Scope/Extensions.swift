//
//  Extensions.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import Foundation

extension Date {
    var dayOfTheWeek: DaysOfTheWeek {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        
        switch weekday {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return .monday
        }
    }
    
    func adding(minutes: Int) -> Date? {
            return Calendar.current.date(byAdding: .minute, value: minutes, to: self)
        }
        
        func adding(hours: Int) -> Date? {
            return Calendar.current.date(byAdding: .hour, value: hours, to: self)
        }
        
        func adding(days: Int) -> Date? {
            return Calendar.current.date(byAdding: .day, value: days, to: self)
        }
        
        func adding(weeks: Int) -> Date? {
            return Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self)
        }
        
        func adding(months: Int) -> Date? {
            return Calendar.current.date(byAdding: .month, value: months, to: self)
        }
        
        func adding(years: Int) -> Date? {
            return Calendar.current.date(byAdding: .year, value: years, to: self)
        }
    
    func formattedHMTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self)
    }
}


extension Notification.Name {
    static let didUpdateCountdown = Notification.Name("didUpdateCountdown")
}
