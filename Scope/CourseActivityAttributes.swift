//
//  CourseActivityAttributes.swift
//  Scope
//
//  Created by Ari Reitman on 9/11/24.
//

import ActivityKit
import Foundation

struct CourseActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var courseName: String
        var startTime: Date
        var endTime: Date
        var isOngoing: Bool
        var showPromptToOpenApp: Bool
    }

    var courseName: String
}
