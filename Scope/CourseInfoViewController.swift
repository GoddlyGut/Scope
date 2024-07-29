//
//  CourseInfoViewController.swift
//  Scope
//
//  Created by Ari Reitman on 7/26/24.
//

import UIKit

class CourseInfoViewController: UIViewController {
    let stackView = UIStackView()
    let label = UILabel()
    let teacherLabel = UILabel()
    
    
    var course: Course
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
    }
    
    init(course: Course) {
        self.course = course
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseInfoViewController {
    func style() {
        view.backgroundColor = .systemBackground
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = course.name
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        
        stackView.addArrangedSubview(label)
        
        
        teacherLabel.translatesAutoresizingMaskIntoConstraints = false
        teacherLabel.text = course.instructor
        teacherLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        
        stackView.addArrangedSubview(teacherLabel)
        
        
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let sortedMeetings = course.schedule.meetings.sorted(by: { $0.day.rawValue < $1.day.rawValue })
        
        for meeting in sortedMeetings {
            formatter.dateFormat = "HH:mm"
            if let startTime = formatter.date(from: meeting.startTime),
               let endTime = formatter.date(from: meeting.endTime) {
                formatter.dateFormat = "h:mm a"
                let formattedStartTime = formatter.string(from: startTime)
                let formattedEndTime = formatter.string(from: endTime)
                
                let meetingLabel = UILabel()
                meetingLabel.text = "\(meeting.day): " +  formattedStartTime + "-" + formattedEndTime
                
                if meeting.day == Date().dayOfTheWeek {
                    meetingLabel.backgroundColor = .pink
                }
                
                stackView.addArrangedSubview(meetingLabel)
            }
            
        }
    }
    
    func layout() {
        
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


