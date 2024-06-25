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
        courseTimingLabel.text = "\(course.daysMeeting.first?.beginTime.formattedHMTime() ?? "") - \(course.daysMeeting.first?.endTime.formattedHMTime() ?? "")"
    }

    
}
