//
//  CourseCell.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import UIKit

class CourseCell: UITableViewCell {
    var course: Course?
    let courseNameLabel = UILabel()
    let courseTimingLabel = UILabel()
    
    var greenDotView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layout()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .didUpdateCountdown, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        layout()
    }
    
    @objc func updateUI(notification: Notification) {
        if CourseViewModel.shared.currentCourse() == course {
            greenDotView.isHidden = false
        }
        else {
            greenDotView.isHidden = true
        }
    }
    
    private func setupViews() {
        courseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        courseTimingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(courseNameLabel)
        contentView.addSubview(courseTimingLabel)
        
        
        courseNameLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        courseTimingLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        courseTimingLabel.textColor = .gray
        
        greenDotView.translatesAutoresizingMaskIntoConstraints = false
        greenDotView.backgroundColor = .systemGreen
        greenDotView.isHidden = true
        greenDotView.layer.cornerRadius = 10 / 2
        contentView.addSubview(greenDotView)
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            courseNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            courseNameLabel.trailingAnchor.constraint(equalTo: greenDotView.leadingAnchor, constant: -16), // Adjusting to leave space for the green dot
            courseNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            courseTimingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            courseTimingLabel.trailingAnchor.constraint(equalTo: greenDotView.leadingAnchor, constant: -16), // Adjusting to leave space for the green dot
            courseTimingLabel.topAnchor.constraint(equalTo: courseNameLabel.bottomAnchor, constant: 4),
            courseTimingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            greenDotView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            greenDotView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16), // Make sure it's inside the content view
            greenDotView.heightAnchor.constraint(equalToConstant: 10),
            greenDotView.widthAnchor.constraint(equalTo: greenDotView.heightAnchor) // Make it a circle
        ])
    }

    func configure(with course: Course, block: Block, dayType: ScheduleType) {
        self.course = course
        courseNameLabel.text = "\(course.name)•Block \(block.blockNumber)"

        // Formatter to convert 24-hour time to 12-hour time with AM/PM
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensure 24-hour time interpretation

        // Format the start and end times for the block
        guard let startTime = formatter.date(from: block.startTime),
              let endTime = formatter.date(from: block.endTime) else {
            courseTimingLabel.text = "Invalid time format"
            return
        }
        
        formatter.dateFormat = "h:mm a"  // Change format to 12-hour with AM/PM
        let formattedStartTime = formatter.string(from: startTime)
        let formattedEndTime = formatter.string(from: endTime)
        
        // Set the label text with the formatted timing
        courseTimingLabel.text = "\(formattedStartTime) - \(formattedEndTime)"

        // Determine if this course is the current course
        if let currentCourse = CourseViewModel.shared.currentCourse(), currentCourse == course {
            greenDotView.isHidden = false
        } else {
            greenDotView.isHidden = true
        }
    }

    
}
