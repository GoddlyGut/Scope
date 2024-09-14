//
//  CourseActivityWidgetExtensionLiveActivity.swift
//  CourseActivityWidgetExtension
//
//  Created by Ari Reitman on 9/11/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CourseActivityWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CourseActivityWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CourseActivityWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CourseActivityWidgetExtensionAttributes {
    fileprivate static var preview: CourseActivityWidgetExtensionAttributes {
        CourseActivityWidgetExtensionAttributes(name: "World")
    }
}

extension CourseActivityWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: CourseActivityWidgetExtensionAttributes.ContentState {
        CourseActivityWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CourseActivityWidgetExtensionAttributes.ContentState {
         CourseActivityWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CourseActivityWidgetExtensionAttributes.preview) {
   CourseActivityWidgetExtensionLiveActivity()
} contentStates: {
    CourseActivityWidgetExtensionAttributes.ContentState.smiley
    CourseActivityWidgetExtensionAttributes.ContentState.starEyes
}
