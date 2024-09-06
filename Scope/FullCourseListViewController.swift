//
//  FullCourseListViewController.swift
//  Scope
//
//  Created by Ari Reitman on 8/21/24.
//

import UIKit

class FullCourseListViewController: UIViewController {
    let stackView = UIStackView()
    let coursesTableView = UITableView()

    let newCourseButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .didUpdateCourseList, object: nil)
        
        setupTableView()
        style()
        layout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupTableView() {
        coursesTableView.translatesAutoresizingMaskIntoConstraints = false
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
        coursesTableView.register(FullCourseCell.self, forCellReuseIdentifier: "FullCourseCell")
    }
}

extension FullCourseListViewController {
    func style() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "Courses"
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(coursesTableView)
        
        newCourseButton.translatesAutoresizingMaskIntoConstraints = false
        newCourseButton.setTitle("Add Course", for: .normal)
        newCourseButton.addTarget(self, action: #selector(openCreateCourseView), for: .touchUpInside)
        view.addSubview(newCourseButton)
    }
    
    func layout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            newCourseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newCourseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
        ])
    }
    
    @objc func openCreateCourseView() {
        present(UINavigationController(rootViewController: NewCourseViewController(course: nil)), animated: true)
    }
    
    @objc func updateUI() {
        coursesTableView.reloadData()
    }
}


extension FullCourseListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CourseViewModel.shared.courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FullCourseCell", for: indexPath) as! FullCourseCell
        let course = CourseViewModel.shared.courses[indexPath.row]
        cell.configure(with: course)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // Deselect the row (optional)
            tableView.deselectRow(at: indexPath, animated: true)
            
            // Get the selected course
            let selectedCourse = CourseViewModel.shared.courses[indexPath.row]
            
            // Initialize the CourseDetailViewController
        let detailVC = NewCourseViewController(course: selectedCourse)
            
            // Pass the selected course to the detail view controller
            
            // Push the CourseDetailViewController onto the navigation stack
            navigationController?.pushViewController(detailVC, animated: true)
        }
}



class FullCourseCell: UITableViewCell {
    let courseNameLabel = UILabel()
    let daysLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        courseNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        daysLabel.font = UIFont.systemFont(ofSize: 14)
        daysLabel.textColor = .gray

        courseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(courseNameLabel)
        contentView.addSubview(daysLabel)
    }

    private func layoutViews() {
        NSLayoutConstraint.activate([
            courseNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            courseNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            courseNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            daysLabel.topAnchor.constraint(equalTo: courseNameLabel.bottomAnchor, constant: 4),
            daysLabel.leadingAnchor.constraint(equalTo: courseNameLabel.leadingAnchor),
            daysLabel.trailingAnchor.constraint(equalTo: courseNameLabel.trailingAnchor),
            daysLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with course: Course) {
        courseNameLabel.text = course.name
        
        // Get the names of the schedule types and join them into a string
        let days = course.schedule.map { $0.scheduleType.name }.joined(separator: ", ")
        daysLabel.text = "Meets on: \(days)"
    }

}
