//
//  NewCourseViewController.swift
//  Scope
//
//  Created by Ari Reitman on 7/30/24.
//

import UIKit

class NewCourseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddNewCourseDelegate {

    
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    var courseSchedule: [CourseDaySchedule] = []
    
    var courseName = ""
    var instructorName = ""
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
        isModalInPresentation = true
        setupTableView()
        configureNavigationBar()
        
        if let course = course {
            courseName = course.name
            instructorName = course.instructor
            courseSchedule = course.schedule
        }
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureNavigationBar() {
        navigationItem.title = course == nil ? "New Course" : "Edit Course"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: course != nil ? "Done" : "Create", style: .done, target: self, action: #selector(doneButtonPressed))
        
        if course == nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissView))
        }
    }
    
    @objc func dismissView() {
        dismiss(animated: true)
    }
    
    @objc func doneButtonPressed() {
        saveCourse()
//        if course != nil {
//            navigationController?.popViewController(animated: true)
//        }
//        else {
            dismiss(animated: true)
        //}
    }
    
    @objc func saveCourse() {
        guard !courseName.isEmpty, !instructorName.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please fill in all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        if var course = course {
            // Update existing course
            course.name = courseName
            course.instructor = instructorName
            course.schedule = courseSchedule
            
            if let index = CourseViewModel.shared.courses.firstIndex(where: { $0.id == course.id }) {
                CourseViewModel.shared.courses[index] = course
                NotificationCenter.default.post(name: .didUpdateCourseListFromCourseManager, object: nil)
            }
        } else {
            // Create new course
            let newCourse = Course(id: UUID(), name: courseName, instructor: instructorName, schedule: courseSchedule)
            CourseViewModel.shared.courses.append(newCourse)
            NotificationCenter.default.post(name: .didUpdateCourseListFromCourseManager, object: nil)
        }
        
        
    }
    
    // MARK: - Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // One section for the form fields, one for the schedule
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return courseSchedule.isEmpty ? 1 : courseSchedule.count
        }
        return 2 // Assuming section 0 is for course name and instructor
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // For the first section (form fields)
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            // Ensure the content view is cleared to avoid duplication
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            
            var textField: UITextField!
            if let existingTextField = cell.contentView.viewWithTag(1000 + indexPath.row) as? UITextField {
                textField = existingTextField
            } else {
                textField = UITextField(frame: CGRect(x: 150, y: 0, width: 200, height: 44))
                textField.tag = 1000 + indexPath.row
                textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
                cell.contentView.addSubview(textField)
            }
            
            if indexPath.row == 0 {
                // Course Name field
                cell.textLabel?.text = "Course Name:"
                textField.placeholder = "Enter course name"
                textField.text = courseName
            } else if indexPath.row == 1 {
                // Instructor Name field
                cell.textLabel?.text = "Instructor:"
                textField.placeholder = "Enter instructor name"
                textField.text = instructorName
            }
            
            return cell
        } else {
            if courseSchedule.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
                cell.textLabel?.text = "None"
                cell.textLabel?.textColor = .gray
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
                let schedule = courseSchedule[indexPath.row]
                cell.configure(with: schedule)
                cell.textLabel?.textColor = .label
                cell.selectionStyle = .default
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            // Programmatically trigger the swipe actions for the selected row
            tableView.setEditing(true, animated: true)

            // Deselect the row so that the swipe remains but the row is not highlighted
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return courseSchedule.isEmpty ? false : indexPath.section == 1 // Allow editing only for section 1
    }

    
    // Header for each section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create a header view for the "Course Information" and "Schedule" sections
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground
        
        // Create the label for the section title
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        // Set title based on the section
        if section == 0 {
            titleLabel.text = "Course Information"
        } else {
            titleLabel.text = "Schedule"
            
            // Add a button on the right-hand side for adding new schedule
            let addButton = UIButton(type: .system)
            addButton.setTitle("Add", for: .normal)
            addButton.tintColor = .pink
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.addTarget(self, action: #selector(createNewCourse), for: .touchUpInside)
            headerView.addSubview(addButton)
            
            // Set up constraints for the button to be on the right-hand side
            NSLayoutConstraint.activate([
                addButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                addButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ])
        }
        
        // Set up constraints for the title label (left-aligned)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Allow deletion only for rows in section 1
        if editingStyle == .delete && indexPath.section == 1 {
            // Update your data model: remove the schedule from the courseSchedule array
            courseSchedule.remove(at: indexPath.row)
            
            // If applicable, update the course's schedule
            if var course = course {
                course.schedule = courseSchedule
                // Update the course in the view model
                if let index = CourseViewModel.shared.courses.firstIndex(where: { $0.id == course.id }) {
                    CourseViewModel.shared.courses[index] = course
                    NotificationCenter.default.post(name: .didUpdateCourseListFromCourseManager, object: nil)
                }
            }
            
            // If courseSchedule is now empty, reload the section to show "None"
            if courseSchedule.isEmpty {
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                // Perform batch update to delete the row from the table view
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }, completion: nil)
            }
        }
    }


    
    //func
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28 // Adjust this value for more spacing
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        if textField.tag == 1000 {
            courseName = textField.text ?? ""
        } else if textField.tag == 1001 {
            instructorName = textField.text ?? ""
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Disable selection for section 0
        if indexPath.section == 0 {
            return nil // Returning nil prevents the row from being selected
        }
        return indexPath // Enable selection for other sections
    }

    
    @objc func createNewCourse() {
        var vc = AddDayViewController(courseSchedule: courseSchedule)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func addDay(scheduleType: ScheduleType, blockNumbers: [Int]) {
        if let index = courseSchedule.firstIndex(where: { $0.scheduleType.id == scheduleType.id }) {
            // If the day exists, check if the blockNumbers are already added
            var existingSchedule = courseSchedule[index]
            let existingBlockNumbers = Set(existingSchedule.courseBlocks.map { $0.blockNumber })
            let newBlockNumbers = Set(blockNumbers)

            // Add only the new blocks that are not present
            let additionalBlocks = newBlockNumbers.subtracting(existingBlockNumbers)
            let newCourseBlocks = additionalBlocks.map { CourseBlock(courseName: courseName, blockNumber: $0) }

            existingSchedule.courseBlocks.append(contentsOf: newCourseBlocks)

            // Update the courseSchedule with the modified schedule
            courseSchedule[index] = existingSchedule
        } else {
            // If the day doesn't exist, create a new schedule with the blocks
            let courseBlocks = blockNumbers.map { CourseBlock(courseName: courseName, blockNumber: $0) }
            let newSchedule = CourseDaySchedule(id: UUID(), scheduleType: scheduleType, courseBlocks: courseBlocks)
            courseSchedule.append(newSchedule)
        }
        
        if course != nil {
            saveCourse() // Update and save the course
        }

        // Reload the table view to reflect the updated schedule
        tableView.reloadData()
    }

}

// MARK: - ScheduleCell for displaying schedule blocks
class ScheduleCell: UITableViewCell {
    func configure(with schedule: CourseDaySchedule) {
        textLabel?.text = "\(schedule.scheduleType.name): \(schedule.courseBlocks.map { "Block \($0.blockNumber)" }.joined(separator: ", "))"
    }
}

class AddDayViewController: UIViewController {
    let stackView = UIStackView()
    let schedulePicker = UIPickerView()
    let blockPicker = UIPickerView()
    let addButton = UIButton(type: .system)
    //let closeButton = CloseButtonView()
    
    var delegate: AddNewCourseDelegate?
    var courseSchedule: [CourseDaySchedule]
    var currentBlocks: [Block] = [] {
        didSet {
            blockPicker.reloadAllComponents() // Reload block picker when blocks change
        }
    }
    
    var selectedBlock: Block?
    
    init(courseSchedule: [CourseDaySchedule]) {
        self.courseSchedule = courseSchedule
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupPickers()
        layoutUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Add Day"
        
        
        // Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Schedule picker
        let schedulePickerContainer = createFormField(title: "Select Day Type", picker: schedulePicker)
        stackView.addArrangedSubview(schedulePickerContainer)
        
        // Block picker
        let blockPickerContainer = createFormField(title: "Select Block", picker: blockPicker)
        stackView.addArrangedSubview(blockPickerContainer)
        
        addButton.setTitle("Add Day", for: .normal)
        addButton.backgroundColor = .pink
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 8
        addButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.addTarget(self, action: #selector(add), for: .touchUpInside)
        stackView.addArrangedSubview(addButton)
    }
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupPickers() {
        var selectedDay: ScheduleType!
        if CourseViewModel.shared.scheduleTypes.isEmpty {
            selectedDay = ScheduleType.none
        }
        else {
            selectedDay = CourseViewModel.shared.scheduleTypes[0]
        }
        
        // Filter blocks that have already been used
        let blocks = CourseViewModel.shared.blocksByScheduleType[selectedDay.id] ?? []
        let usedBlockNumbers = courseSchedule
            .first(where: { $0.scheduleType.id == selectedDay.id })?
            .courseBlocks.map { $0.blockNumber } ?? []
        
        currentBlocks = blocks.filter { !usedBlockNumbers.contains($0.blockNumber) }
        currentBlocks.sort { $0.blockNumber < $1.blockNumber }
        
        schedulePicker.dataSource = self
        schedulePicker.delegate = self
        
        blockPicker.dataSource = self
        blockPicker.delegate = self
        
        // Select first default values
        schedulePicker.selectRow(0, inComponent: 0, animated: false)
        blockPicker.selectRow(0, inComponent: 0, animated: false)
        
        pickerView(schedulePicker, didSelectRow: 0, inComponent: 0)
        pickerView(blockPicker, didSelectRow: 0, inComponent: 0)
    }
    
    private func createFormField(title: String, picker: UIPickerView) -> UIStackView {
        let formFieldStack = UIStackView()
        formFieldStack.axis = .vertical
        formFieldStack.spacing = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        
        formFieldStack.addArrangedSubview(titleLabel)
        formFieldStack.addArrangedSubview(picker)
        
        return formFieldStack
    }
    
    @objc func close() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func add() {
        let scheduleTypes = CourseViewModel.shared.scheduleTypes
        let selectedDayIndex = schedulePicker.selectedRow(inComponent: 0)
        
        if scheduleTypes.isEmpty {
            showErrorAlert(message: "Please select a valid schedule day.")
            return
        }
        
        let selectedDayType = scheduleTypes[selectedDayIndex]
        
        let selectedBlockIndex = blockPicker.selectedRow(inComponent: 0)
        
        
        if currentBlocks.isEmpty {
            showErrorAlert(message: "Please select a valid block.")
            return
        }
        let selectedBlock = currentBlocks[selectedBlockIndex]
        
        if let existingSchedule = courseSchedule.first(where: { $0.scheduleType.id == selectedDayType.id }) {
            if existingSchedule.courseBlocks.contains(where: { $0.blockNumber == selectedBlock.blockNumber }) {
                showErrorAlert(message: "This block has already been added for the selected day.")
                return
            }
        }
        
        delegate?.addDay(scheduleType: selectedDayType, blockNumbers: [selectedBlock.blockNumber])
        navigationController?.popViewController(animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
extension AddDayViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == schedulePicker {
            let count = CourseViewModel.shared.scheduleTypes.count
            return count == 0 ? 1 : count // Show 1 row if "None" needs to be displayed
        } else if pickerView == blockPicker {
            let count = currentBlocks.count
            return count == 0 ? 1 : count // Show 1 row if "None" needs to be displayed
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == schedulePicker {
            return CourseViewModel.shared.scheduleTypes.isEmpty ? "None" : CourseViewModel.shared.scheduleTypes[row].name
        } else if pickerView == blockPicker {
            if currentBlocks.isEmpty {
                return "None"
            }
            else {
                if let startTime = CourseViewModel.shared.combineDateAndTime(date: Date(), time: currentBlocks[row].startTime)?.formattedHMTime(),
                   let endTime = CourseViewModel.shared.combineDateAndTime(date: Date(), time: currentBlocks[row].endTime)?.formattedHMTime() {
                    return currentBlocks.isEmpty ? "None" : "Block \(currentBlocks[row].blockNumber): \(startTime) - \(endTime)"
                } else {
                    return currentBlocks.isEmpty ? "None" : "Block \(currentBlocks[row].blockNumber): \(currentBlocks[row].startTime) - \(currentBlocks[row].endTime)"
                }
            }
            
            
            
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == schedulePicker {
            if CourseViewModel.shared.scheduleTypes.isEmpty {
                schedulePicker.isUserInteractionEnabled = false // Disable the picker if "None" is shown
            } else {
                schedulePicker.isUserInteractionEnabled = true
                let selectedDay = CourseViewModel.shared.scheduleTypes[row]
                
                // Filter blocks that have already been used
                let blocks = CourseViewModel.shared.blocksByScheduleType[selectedDay.id] ?? []
                let usedBlockNumbers = courseSchedule
                    .first(where: { $0.scheduleType.id == selectedDay.id })?
                    .courseBlocks.map { $0.blockNumber } ?? []
                
                currentBlocks = blocks.filter { !usedBlockNumbers.contains($0.blockNumber) }
                currentBlocks.sort { $0.blockNumber < $1.blockNumber }
                
                blockPicker.reloadAllComponents() // Reload block picker with the filtered blocks
            }
        } else if pickerView == blockPicker {
            if currentBlocks.isEmpty {
                //blockPicker.isUserInteractionEnabled = false // Disable the picker if "None" is shown
            } else {
                //blockPicker.isUserInteractionEnabled = true
                selectedBlock = currentBlocks[row]
            }
        }
    }
}
