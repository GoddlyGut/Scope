//
//  NewCourseViewController.swift
//  Scope
//
//  Created by Ari Reitman on 7/30/24.
//

import Foundation
import UIKit
import CloudKit

class NewCourseViewController: UIViewController, AddNewCourseDelegate {
    
    let stackView = UIStackView()
    let courseNameTextField = UITextField()
    let instructorTextField = UITextField()
    let scheduleTableView = UITableView()
    let addButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    var closeButton = CloseButtonView()
    var courseSchedule: [CourseDaySchedule] = [] {
        didSet {
            scheduleTableView.reloadData()
        }
    }
    
    var course: Course?
    
    init(course: Course?) {
        self.course = course
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        style()
        layout()
        configureButtons()
        
        // Load existing course data if available
        if let course = course {
            courseNameTextField.text = course.name
            instructorTextField.text = course.instructor
            courseSchedule = course.schedule
        }
    }
    
    private func setupTableView() {
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        scheduleTableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
    }
    
    func addDay(scheduleType: ScheduleType, blockNumbers: [Int]) {
        let courseBlocks = blockNumbers.map { CourseBlock(courseName: courseNameTextField.text ?? "", blockNumber: $0) }
        let newSchedule = CourseDaySchedule(scheduleType: scheduleType, courseBlocks: courseBlocks)
        self.courseSchedule.append(newSchedule)
    }
}

extension NewCourseViewController {
    func style() {
            view.backgroundColor = .systemBackground
            
            navigationItem.title = course == nil ? "New Course" : "Edit Course Info"
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 10  // Reduced spacing for a tighter form look

            // Course Name Section
            let courseNameLabel = UILabel()
            courseNameLabel.text = "Course Name"
            courseNameLabel.font = .systemFont(ofSize: 16, weight: .bold)

            courseNameTextField.translatesAutoresizingMaskIntoConstraints = false
            courseNameTextField.borderStyle = .roundedRect
            
            // Instructor Section
            let instructorLabel = UILabel()
            instructorLabel.text = "Instructor"
            instructorLabel.font = .systemFont(ofSize: 16, weight: .bold)

            instructorTextField.translatesAutoresizingMaskIntoConstraints = false
            instructorTextField.borderStyle = .roundedRect

            // Schedule Section
            let scheduleLabel = UILabel()
            scheduleLabel.text = "Schedule"
            scheduleLabel.font = .systemFont(ofSize: 16, weight: .bold)

            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.setTitle("Add Blocks", for: .normal)
            addButton.backgroundColor = .systemBlue
            addButton.tintColor = .white
            addButton.layer.cornerRadius = 8
            addButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

            // Save Button
            saveButton.translatesAutoresizingMaskIntoConstraints = false
            saveButton.setTitle(course == nil ? "Create Course" : "Update Course", for: .normal)
            saveButton.backgroundColor = .pink
            saveButton.tintColor = .white
            saveButton.layer.cornerRadius = 8
            saveButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

            // Adding elements to stack view
            stackView.addArrangedSubview(courseNameLabel)
            stackView.addArrangedSubview(courseNameTextField)
            stackView.addArrangedSubview(instructorLabel)
            stackView.addArrangedSubview(instructorTextField)
            stackView.addArrangedSubview(scheduleLabel)
            stackView.addArrangedSubview(scheduleTableView)
            stackView.addArrangedSubview(addButton)
            view.addSubview(saveButton)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
            closeButton.circle.addTarget(self, action: #selector(close), for: .touchUpInside)
            view.addSubview(stackView)
        }
        
        func layout() {
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                saveButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                saveButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                
                scheduleTableView.heightAnchor.constraint(equalToConstant: 150)
                
                
            ])
        }
    
    func configureButtons() {
        addButton.addTarget(self, action: #selector(addSchedule), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveCourse), for: .touchUpInside)
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
    
    @objc func addSchedule() {
        let alertController = AddDayViewController()
        alertController.delegate = self
        present(UINavigationController(rootViewController: alertController), animated: true, completion: nil)
    }
    
    @objc func saveCourse() {
        guard let courseName = courseNameTextField.text, !courseName.isEmpty,
              let instructor = instructorTextField.text, !instructor.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please fill in all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        if var course = course {
            // Update existing course
            course.name = courseName
            course.instructor = instructor
            course.schedule = courseSchedule
            
            if let index = CourseViewModel.shared.courses.firstIndex(where: { $0.id == course.id }) {
                CourseViewModel.shared.courses[index] = course
            }
        } else {
            // Create a new course
            let newCourse = Course(id: UUID(), name: courseName, instructor: instructor, schedule: courseSchedule)
            CourseViewModel.shared.courses.append(newCourse)
        }
        if course == nil {
            dismiss(animated: true)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
        navigationController?.popViewController(animated: true)
    }
}

extension NewCourseViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseSchedule.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             courseSchedule.remove(at: indexPath.row)
         }
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        let schedule = courseSchedule[indexPath.row]
        cell.configure(with: schedule)
        return cell
    }
}

class ScheduleCell: UITableViewCell {
    func configure(with schedule: CourseDaySchedule) {
        textLabel?.text = "\(schedule.scheduleType.name): \(schedule.courseBlocks.map { "Block \($0.blockNumber)" }.joined(separator: ", "))"
    }
}



class AddDayViewController: UIViewController {
    let stackView = UIStackView()
    var dayLabel = UILabel()
    var blockLabel = UILabel()
    var schedulePicker = UIPickerView()
    var blockPicker = UIPickerView()
    let formatter = DateFormatter()
    var addButton = UIButton()
    var closeButton = CloseButtonView()
    var delegate: AddNewCourseDelegate?
    
    var currentBlocks: [Block] = [] {
        didSet {
            blockPicker.reloadAllComponents() // Reload block picker when blocks change
        }
    }
    
    var selectedBlock: Block?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
        formatter.dateFormat = "HH:mm"
        schedulePicker.dataSource = self
        schedulePicker.delegate = self
        
        blockPicker.dataSource = self
        blockPicker.delegate = self
        

        let defaultScheduleIndex = 0 // Default to the first schedule type (A Day)
            schedulePicker.selectRow(defaultScheduleIndex, inComponent: 0, animated: false)
            pickerView(schedulePicker, didSelectRow: defaultScheduleIndex, inComponent: 0)
            
            let defaultBlockIndex = 0 // Default to the first block
            blockPicker.selectRow(defaultBlockIndex, inComponent: 0, animated: false)
            pickerView(blockPicker, didSelectRow: defaultBlockIndex, inComponent: 0)
    }
}

extension AddDayViewController {
    func style() {
        view.backgroundColor = .systemBackground
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        dayLabel.text = "Chosen day: A Day"
        stackView.addArrangedSubview(dayLabel)
        
        stackView.addArrangedSubview(schedulePicker)
        
        blockLabel.text = "Selected: Block 1"
        stackView.addArrangedSubview(blockLabel)
        stackView.addArrangedSubview(blockPicker)
        
        addButton.setTitle("Add", for: .normal)
        addButton.tintColor = .pink
        addButton.addTarget(self, action: #selector(add), for: .touchUpInside)
        stackView.addArrangedSubview(addButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        closeButton.circle.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    func layout() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
    
    @objc func add() {
        // Access the dynamic schedule types from CourseViewModel
        let scheduleTypes = CourseViewModel.shared.scheduleTypes
        
        // Get the selected schedule type from the picker
        let selectedDayIndex = schedulePicker.selectedRow(inComponent: 0)
        let selectedDayType = scheduleTypes[selectedDayIndex]
        
        // Get the selected block from the block picker
        let selectedBlockIndex = blockPicker.selectedRow(inComponent: 0)
        let selectedBlock = currentBlocks[selectedBlockIndex]
        
        // Dismiss the view and call the delegate method with the selected schedule type and block number
        self.dismiss(animated: true)
        delegate?.addDay(scheduleType: selectedDayType, blockNumbers: [selectedBlock.blockNumber])
    }

}

extension AddDayViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    // Schedule Picker Data Source & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single column for both pickers
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == schedulePicker {
            // Use the dynamic schedule types from CourseViewModel
            return CourseViewModel.shared.scheduleTypes.count
        } else if pickerView == blockPicker {
            return currentBlocks.count
        }
        return 0
    }

    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == schedulePicker {
            // Use the dynamic schedule types from CourseViewModel
            let scheduleType = CourseViewModel.shared.scheduleTypes[row]
            return scheduleType.name
        } else if pickerView == blockPicker {
            let block = currentBlocks[row]
            return "Block \(block.blockNumber): \(formatter.date(from: block.startTime)?.formattedHMTime() ?? "") - \(formatter.date(from: block.endTime)?.formattedHMTime() ?? "")"
        }
        return nil
    }

    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == schedulePicker {
            // Get the selected schedule type from the dynamic list
            if !CourseViewModel.shared.scheduleTypes.isEmpty {
                let selectedDay = CourseViewModel.shared.scheduleTypes[row]
                dayLabel.text = "Chosen day: \(selectedDay.name)"
                // Fetch the blocks associated with the selected schedule type
                if let blocks = CourseViewModel.shared.blocksByScheduleType[selectedDay.id] {
                    currentBlocks = blocks
                } else {
                    currentBlocks = []
                }
            }
            else {
                
                dayLabel.text = "Chosen day: None"
            }
            
            
            
            // Reload the block picker to reflect the selected schedule type
            blockPicker.reloadAllComponents()
            
        } else if pickerView == blockPicker {
            // Set the selected block based on the current blocks for the selected schedule type
            if currentBlocks.isEmpty {
                blockLabel.text = "Selected: None"
            }
            else {
                selectedBlock = currentBlocks[row]
                blockLabel.text = "Selected: Block \(selectedBlock?.blockNumber ?? 0)"
            }
            
            // Here you can update the UI to reflect the selected block
        }
    }

}

extension AddDayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentBlocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath)
        let block = currentBlocks[indexPath.row]
        
        cell.textLabel?.text = "Block \(block.blockNumber): \(formatter.date(from: block.startTime)?.formattedHMTime() ?? "") - \(formatter.date(from: block.endTime)?.formattedHMTime() ?? "")"
        return cell
    }
}

