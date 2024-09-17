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

                    if !context.state.showPromptToOpenApp {
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
                    DynamicIslandExpandedRegion(.center) {
                        HStack {
                            VStack {
                                if !context.state.isOngoing {
                                    Text("Up next:")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                        .multilineTextAlignment(.trailing)
                                }
                                Text("\(context.state.courseName)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) { // Align content of VStack to the trailing edge
                                Text(context.state.isOngoing ? "Time left:" : "Starts in:")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .multilineTextAlignment(.trailing)
                                // Use the exact same endTime used in the app's live activity
                                let now = Date()
                                let time = context.state.isOngoing ? context.state.endTime : context.state.startTime // This timeRemaining comes from the live activity state
                                
                                
                                // Adjust to match the app's exact time
                                Text(timerInterval: now...time, countsDown: true)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: 200)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 16)
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
                }
            )
        }

    }
}

