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




protocol AddNewCourseDelegate {
    func addDay(scheduleType: ScheduleType, blockNumbers: [Int])
}
