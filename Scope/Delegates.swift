//
//  Delegates.swift
//  Scope
//
//  Created by Ari Reitman on 7/26/24.
//

import Foundation


protocol BottomSheetDelegate {
    func openCourseInfoPage()
    
}

protocol CreateNewCourseDelegate: AnyObject {
    func didSaveCourse(_ course: Course)
    func didCancel()
}



protocol AddNewCourseDelegate {
    func addDay(scheduleType: ScheduleType, blockNumbers: [Int])
}
