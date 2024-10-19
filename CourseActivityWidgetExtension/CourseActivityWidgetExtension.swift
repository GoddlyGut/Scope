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
            let now = Date()
            let endTime = context.state.endTime
            let startTime = context.state.startTime

            // Calculate the total and elapsed time
            let totalDuration = endTime.timeIntervalSince(startTime)
            let elapsedTime = now.timeIntervalSince(startTime)
            let progress = totalDuration > 0 ? elapsedTime / totalDuration : 0
            
            
                // Regular widget content
                HStack {
                    VStack(alignment: .leading) {
                        if !context.state.isOngoing {
                            Text("Up next:")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                        }
                        Text("\(context.state.courseName)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    if !context.isStale {
                        VStack(alignment: .trailing) {
                            Text(context.state.isOngoing ? "Time left:" : "Starts in:")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .multilineTextAlignment(.trailing)

                            // Show the timer
                            Text(timerInterval: now...(context.state.isOngoing ? endTime : startTime), countsDown: true)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.trailing)
                        }
                    } else {
                        VStack(alignment: .trailing) {
                            Image(systemName: "chevron.right")

                            // Show the timer
                            Text("Open app to resume!")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    
                }

                if context.state.isOngoing {
                    // Horizontal progress bar
                    ProgressView(
                        timerInterval: startTime...endTime,
                        countsDown: false,
                        label: { EmptyView() },
                        currentValueLabel: { EmptyView() }
                    )
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(.pink)
                }
            }
        
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
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
                    DynamicIslandExpandedRegion(.leading) {
                        VStack(alignment: .leading) {
                            Spacer()
                            if !context.state.isOngoing {
                                Text("Up next:")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .multilineTextAlignment(.leading)
                            }
                            Text("\(context.state.courseName)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.leading)
                        

                    }
                    
                    DynamicIslandExpandedRegion(.trailing) {
                        let now = Date()
                        let endTime = context.state.endTime
                        let startTime = context.state.startTime

                        // Calculate the total and elapsed time
                        let totalDuration = endTime.timeIntervalSince(startTime)
                        let elapsedTime = now.timeIntervalSince(startTime)
                        let progress = totalDuration > 0 ? elapsedTime / totalDuration : 0
                        
                        if !context.state.showPromptToOpenApp {
                            VStack(alignment: .trailing) {
                                Spacer()
                                Text(context.state.isOngoing ? "Time left:" : "Starts in:")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .multilineTextAlignment(.trailing)

                                // Show the timer
                                Text(timerInterval: now...(context.state.isOngoing ? endTime : startTime), countsDown: true)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.trailing)
                                Spacer()
                            }
                            .padding(.trailing)
                        } else {
                            VStack(alignment: .trailing) {
                                Spacer()
                                Image(systemName: "chevron.right")

                                // Show the timer
                                Text("Open app to resume!")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.trailing)
                                Spacer()
                            }
                            .padding(.trailing)
                        }

                    }
                    
                    

                    
                    
                    
                    DynamicIslandExpandedRegion(.bottom) {
                        let now = Date()
                        let endTime = context.state.endTime
                        let startTime = context.state.startTime
                        
                        if context.state.isOngoing {
                            // Horizontal progress bar
                            ProgressView(
                                timerInterval: startTime...endTime,
                                countsDown: false,
                                label: { EmptyView() },
                                currentValueLabel: { EmptyView() }
                            )
                            .progressViewStyle(LinearProgressViewStyle())
                            .tint(.pink)
                            .padding(.horizontal)
                        }

                        
                    }
                },
                compactLeading: {
                    let endTime = context.state.endTime
                    let startTime = context.state.startTime
                    if context.state.isOngoing {
                        ProgressView(
                            timerInterval: startTime...endTime,
                            countsDown: false,
                            label: { EmptyView() },
                            currentValueLabel: { EmptyView() }
                        )
                        .progressViewStyle(.circular)
                        .tint(.pink)
                    }
                    else {
                        Image(systemName: "figure.walk.motion")
                            .foregroundStyle(.white)
                    }
                    
                        
                },
                compactTrailing: {
                    if context.state.isOngoing {
                        let now = Date()
                        let endTime = context.state.endTime // This timeRemaining comes from the live activity state

                        // Adjust to match the app's exact time
                        Text(timerInterval: now...endTime, countsDown: true)
                            .frame(maxWidth: 55)
                            .multilineTextAlignment(.trailing)
                    }
                    else {
                        let now = Date()
                        let startTime = context.state.startTime // This timeRemaining comes from the live activity state

                        // Adjust to match the app's exact time
                        Text(timerInterval: now...startTime, countsDown: true)
                            .frame(maxWidth: 55)
                            .multilineTextAlignment(.trailing)
                    }
                    
                },
                minimal: {
                    let endTime = context.state.endTime
                    let startTime = context.state.startTime
                    if context.state.isOngoing {
                        ProgressView(
                            timerInterval: startTime...endTime,
                            countsDown: false,
                            label: { EmptyView() },
                            currentValueLabel: { EmptyView() }
                        )
                        .progressViewStyle(.circular)
                        .tint(.pink)
                    }
                    else {
                        Image(systemName: "figure.walk.motion")
                            .foregroundStyle(.white)
                    }
                }
            )
        }
        
    }
}
//
//struct CourseActivityWidgetExtension: Widget {
//    @Environment(\.activityFamily) var activityFamily
//    let kind: String = "CourseActivityWidgetExtension"
//
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: CourseActivityAttributes.self) { context in
//            // Main widget view for iOS and watchOS
//            CourseActivityWidgetExtensionEntryView(context: context)
//        } dynamicIsland: { context in
//            // Adjust layout for different activity families
//            if activityFamily == .medium {
//                // Expanded layout for larger screens (e.g., iOS)
//                DynamicIsland(
//                    expanded: {
//                        DynamicIslandExpandedRegion(.leading) {
//                            VStack(alignment: .leading) {
//                                Spacer()
//                                if !context.state.isOngoing {
//                                    Text("Up next:")
//                                        .foregroundStyle(.secondary)
//                                        .font(.caption)
//                                        .multilineTextAlignment(.leading)
//                                }
//                                Text("\(context.state.courseName)")
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                                    .multilineTextAlignment(.leading)
//                                Spacer()
//                            }
//                            .padding(.leading)
//                        }
//                        // Other regions omitted for brevity...
//                    },
//                    compactLeading: {
//                        // Content for compact leading region
//                    },
//                    compactTrailing: {
//                        // Content for compact trailing region
//                    },
//                    minimal: {
//                        // Minimal view content
//                    }
//                )
//            } else {
//                
//
//                // Simplified layout for smaller screens (e.g., Apple Watch)
//                DynamicIsland {
//                    DynamicIslandExpandedRegion(.leading) {
//                        
//                    }
//                } compactLeading: {
//                        Image(systemName: "figure.walk.motion")
//                            .foregroundStyle(.white)
//                    }
//                    compactTrailing: {
//                        if context.state.isOngoing {
////                            Text(timerInterval: Date()...context.state.endTime, countsDown: true)
////                                .font(.caption)
////                                .multilineTextAlignment(.trailing)
//                        } else {
////                            Text(timerInterval: Date()...context.state.startTime, countsDown: true)
////                                .font(.caption)
////                                .multilineTextAlignment(.trailing)
//                        }
//                    }
//                    minimal: {
//                        if context.state.isOngoing {
////                            ProgressView(
////                                timerInterval: context.state.startTime...context.state.endTime,
////                                countsDown: false,
////                                label: { EmptyView() },
////                                currentValueLabel: { EmptyView() }
////                            )
////                            .progressViewStyle(.circular)
////                            .tint(.pink)
//                        } else {
//                            Image(systemName: "figure.walk.motion")
//                                .foregroundStyle(.white)
//                        }
//                    }
//                
//            }
//        }
//        .supplementalActivityFamilies([.small, .medium])
//    }
//}
