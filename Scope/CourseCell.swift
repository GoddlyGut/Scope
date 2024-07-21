//
//  CourseCell.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import UIKit

class CourseCell: UITableViewCell {
    let courseNameLabel = UILabel()
    let courseTimingLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        layout()
    }
    
    private func setupViews() {
        courseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        courseTimingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(courseNameLabel)
        contentView.addSubview(courseTimingLabel)
        
        courseNameLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        courseTimingLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        courseTimingLabel.textColor = .gray
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            courseNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            courseNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            courseNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            courseTimingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            courseTimingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            courseTimingLabel.topAnchor.constraint(equalTo: courseNameLabel.bottomAnchor, constant: 4),
            courseTimingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with course: Course) {
        courseNameLabel.text = course.name

        // Determine today's day of the week
        let calendar = Calendar.current
        let today = DaysOfTheWeek(rawValue: calendar.component(.weekday, from: Date()) - 1)!

        // Formatter to convert 24-hour time to 12-hour time with AM/PM
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensure 24-hour time interpretation

        // Iterate over the meetings for the specific course
        var isMeetingFound = false
        for meeting in course.schedule.meetings where meeting.day == today {
            if let startTime = formatter.date(from: meeting.startTime),
               let endTime = formatter.date(from: meeting.endTime) {
                formatter.dateFormat = "h:mm a"  // Change format to 12-hour with AM/PM
                let formattedStartTime = formatter.string(from: startTime)
                let formattedEndTime = formatter.string(from: endTime)
                
                // Set the label text with the formatted timing
                courseTimingLabel.text = "\(formattedStartTime)-\(formattedEndTime)"
                isMeetingFound = true
                break  // Assuming you only want to display the first matching meeting today
            }
        }

        // Handle cases where no meeting is found for today
        if !isMeetingFound {
            courseTimingLabel.text = "No class today"
        }
    }


    
}
