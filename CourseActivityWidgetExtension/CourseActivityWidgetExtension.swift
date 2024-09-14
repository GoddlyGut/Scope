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
            
            VStack(alignment: .trailing) { // Align content of VStack to the trailing edge
                Text(context.state.isOngoing ? "Time left:" : "Starts in:")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
                // Use the exact same endTime used in the app's live activity
                let now = Date()
                let endTime = context.state.endTime // This timeRemaining comes from the live activity state
                
                
                // Adjust to match the app's exact time
                Text(timerInterval: now...endTime, countsDown: true)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 200)
                    .multilineTextAlignment(.trailing)
            }
        }
        
        .padding(.horizontal, 16)

        
        
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
                                let endTime = context.state.endTime // This timeRemaining comes from the live activity state
                                
                                
                                // Adjust to match the app's exact time
                                Text(timerInterval: now...endTime, countsDown: true)
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
                    if context.state.isOngoing {
                        Image(systemName: "clock")
                            .frame(maxWidth: 20)
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
                    Text("Minimal")
                }
            )
        }

    }
}

