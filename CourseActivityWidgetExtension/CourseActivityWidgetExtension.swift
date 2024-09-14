//
//  CourseActivityWidgetExtension.swift
//  CourseActivityWidgetExtension
//
//  Created by Ari Reitman on 9/11/24.
//

import WidgetKit
import SwiftUI
import ActivityKit

struct CourseActivityWidgetExtensionEntryView: View {
    let context: ActivityViewContext<CourseActivityAttributes>

    var body: some View {
        VStack {
            Text("Course: \(context.attributes.courseName)")
                .font(.headline)

            // Use the exact same endTime used in the app's live activity
            let now = Date()
            let endTime = context.state.endTime // This timeRemaining comes from the live activity state

            // Adjust to match the app's exact time
            Text(timerInterval: now...endTime, countsDown: true)
                .font(.body)
        }
    }
}





struct CourseActivityWidgetExtension: Widget {
    let kind: String = "CourseActivityWidgetExtension"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CourseActivityAttributes.self) { context in
            CourseActivityWidgetExtensionEntryView(context: context)
        } dynamicIsland: { context in
            DynamicIsland(
                expanded: {
                    DynamicIslandExpandedRegion(.center) {
                        Text("Expanded View")
                    }
                },
                compactLeading: {
                    Text("Leading")
                },
                compactTrailing: {
                    Text("Trailing")
                },
                minimal: {
                    Text("Minimal")
                }
            )
        }

    }
}

