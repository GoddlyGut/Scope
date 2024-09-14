//
//  CourseActivityWidgetExtensionBundle.swift
//  CourseActivityWidgetExtension
//
//  Created by Ari Reitman on 9/11/24.
//

import WidgetKit
import SwiftUI

@main
struct CourseActivityWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        CourseActivityWidgetExtension()
        CourseActivityWidgetExtensionLiveActivity()
    }
}
