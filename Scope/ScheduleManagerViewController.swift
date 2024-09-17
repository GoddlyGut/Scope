//
//  ScheduleManagerViewController.swift
//  Scope
//
//  Created by Ari Reitman on 9/5/24.
//

import UIKit

protocol TimePickerViewControllerDelegate: AnyObject {
    func didAddBlock(block: Block)
    func didEditBlock(block: Block)
}

class ScheduleManagerViewController: UIViewController {
    
    let viewModel = CourseViewModel.shared
    var tableView = UITableView()
    var closeButton = CloseButtonView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(onScheduleTypeUpdate), name: .didUpdateScheduleTypeFromManager, object: nil)
        
    
    

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onScheduleTypeUpdate() {
        tableView.reloadData()
    }
    
    // Setup the UI for the schedule manager
    func setupUI() {
        title = "Manage Schedules"
        view.backgroundColor = .systemBackground
        
        
        
        // Setup TableView
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Register UITableViewCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ScheduleCell")
        
        // Layout
        NSLayoutConstraint.activate([
 
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditing))
        
        closeButton.circle.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    
    @objc func close() {
        dismiss(animated: true)
    }
    
    // Toggle table view editing mode
    @objc func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.leftBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    @objc func addSchedule() {
        let addScheduleVC = AddScheduleViewController()
        
        // Handle the result from the modal
        addScheduleVC.onScheduleAdded = { [weak self] scheduleName in
            guard let self = self else { return }
            
            // Check if a schedule with the same name already exists
            if self.viewModel.scheduleTypes.contains(where: { $0.name.lowercased() == scheduleName.lowercased() }) {
                // Show an error alert if the name already exists
                let errorAlert = UIAlertController(title: "Error", message: "A schedule with this name already exists. Please choose a different name.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.addSchedule()
                })
                self.present(errorAlert, animated: true)
                
            } else {
                // Create the schedule if the name is unique
                let newScheduleType = self.viewModel.createScheduleType(name: scheduleName)
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.present(UINavigationController(rootViewController: BlockCustomizationViewController(scheduleType: newScheduleType)), animated: true)
                }
                
            }
        }
        
        let navigationController = UINavigationController(rootViewController: addScheduleVC)
        // Present as a half-sheet
        navigationController.modalPresentationStyle = .pageSheet
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.custom(resolver: { context in
                return 200 // Define the height for the sheet here (in points)
            })]  // You can also use .large() or a custom height
            sheet.prefersGrabberVisible = true
        }
        present(navigationController, animated: true, completion: nil)
    }


    
    // Navigate to block customization for selected schedule
    func customizeBlocks(for scheduleType: ScheduleType) {
        let blockVC = BlockCustomizationViewController(scheduleType: scheduleType)
        present(UINavigationController(rootViewController: blockVC), animated: true)
    }
}

extension ScheduleManagerViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGray6
        
        let titleLabel = UILabel()
        titleLabel.text = "Schedules"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        // Add a button next to the "Specific Days" title
        let addButton = UIButton(type: .roundedRect)
        addButton.setTitle("Add", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addSchedule), for: .touchUpInside)
        headerView.addSubview(addButton)
        
        // Layout the label and button within the header view
        NSLayoutConstraint.activate([
            // Layout the title label
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Layout the Add button
            addButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28 // Adjust this value for more spacing
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If the array is empty, return 1 so we can show the "None" cell
        return CourseViewModel.shared.scheduleTypes.isEmpty ? 1 : CourseViewModel.shared.scheduleTypes.count
    }
    
    // Cell for row
    // Cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath)
        
        // Remove existing subviews (reuse behavior)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Custom view for the cell's content
        let customView = UIView()
        customView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(customView)
        
        // Create the block label
        let scheduleLabel = UILabel()
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleLabel.font = UIFont.systemFont(ofSize: 16)

        // Check if the scheduleTypes array is empty and handle it accordingly
        if CourseViewModel.shared.scheduleTypes.isEmpty {
            scheduleLabel.text = "None"
            scheduleLabel.textColor = .gray // Set the text color to gray for "None"
        } else {
            let schedule = CourseViewModel.shared.scheduleTypes[indexPath.row]
            scheduleLabel.text = schedule.name
            scheduleLabel.textColor = .label // Set the text color to default for regular cells
        }
        
        customView.addSubview(scheduleLabel)
        
        // Create the chevron image view (only for non-empty schedule)
        let chevronImageView = UIImageView()
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right") // Use SF Symbol for chevron
        chevronImageView.tintColor = .gray

        // Add the chevron only if there are schedule types
        if !CourseViewModel.shared.scheduleTypes.isEmpty {
            customView.addSubview(chevronImageView)
        }

        // Layout Constraints
        NSLayoutConstraint.activate([
            // Custom view layout
            customView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            customView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            customView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            
            // Block label layout
            scheduleLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 16),
            scheduleLabel.centerYAnchor.constraint(equalTo: customView.centerYAnchor)
        ])
        
        // Add chevron constraints only if there are schedule types
        if !CourseViewModel.shared.scheduleTypes.isEmpty {
            NSLayoutConstraint.activate([
                chevronImageView.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -16),
                chevronImageView.centerYAnchor.constraint(equalTo: customView.centerYAnchor)
            ])
        }
        
        return cell
    }


    
    // Handle row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !viewModel.scheduleTypes.isEmpty {
            let schedule = viewModel.scheduleTypes[indexPath.row]
            customizeBlocks(for: schedule)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // If the scheduleTypes array is empty, return nil to prevent selection
        if CourseViewModel.shared.scheduleTypes.isEmpty {
            return nil
        }
        // Allow selection otherwise
        return indexPath
    }

    
    // Editing: Delete schedule
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // First, update the data model by deleting the schedule
            let schedule = viewModel.scheduleTypes[indexPath.row]
            viewModel.deleteScheduleType(id: schedule.id)

            tableView.reloadData()
            // Then, delete the row from the table view
            //tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}

class AddScheduleViewController: UIViewController {
    
    let stackView = UIStackView()
    let scheduleNameTextField = UITextField()
    let addButton = UIButton(type: .system)
    var onScheduleAdded: ((String) -> Void)?
    var closeButton = CloseButtonView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Create Schedule"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        closeButton.circle.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        // Stack View settings
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        
        // Schedule Name Text Field
        scheduleNameTextField.borderStyle = .none
        scheduleNameTextField.placeholder = "Enter schedule name"
        scheduleNameTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stackView.addArrangedSubview(scheduleNameTextField)
        
        // Add Schedule Button
                addButton.setTitle("Add Schedule", for: .normal)
        addButton.backgroundColor = .pink
                addButton.tintColor = .white
                addButton.layer.cornerRadius = 8
                addButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
                addButton.addTarget(self, action: #selector(addSchedule), for: .touchUpInside)
                stackView.addArrangedSubview(addButton)
        

        
        // StackView Constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    
    
    @objc func addSchedule() {
        guard let scheduleName = scheduleNameTextField.text, !scheduleName.isEmpty else {
            // Show an error if the text field is empty
            let alert = UIAlertController(title: "Error", message: "Please enter a schedule name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Call the completion handler to pass the schedule name back
        
        dismiss(animated: true, completion: nil)
        onScheduleAdded?(scheduleName)
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
}


class BlockCustomizationViewController: UIViewController {

    var scheduleType: ScheduleType
    var tableView = UITableView()
    var availableBlockNumbers: [Int] = []
    var blockName: String = "" // Holds the block name

    init(scheduleType: ScheduleType) {
        self.scheduleType = scheduleType
        blockName = scheduleType.name
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshAvailableBlockNumbers() // Ensure availableBlockNumbers are updated
        isModalInPresentation = true
    }

    // Setup UI for block customization
    func setupUI() {
        title = "Customize \"\(scheduleType.name)\""

        view.backgroundColor = .systemBackground

        // Setup TableView
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Register UITableViewCell
        tableView.register(BlockCustomizationCell.self, forCellReuseIdentifier: "BlockCell")


        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(close))

        // Layout TableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc func close() {
        if let index = CourseViewModel.shared.scheduleTypes.firstIndex(where: { $0.id == scheduleType.id }) {
            print(blockName)
            CourseViewModel.shared.scheduleTypes[index].name = blockName
            
            // Iterate over all courses
            for courseIndex in CourseViewModel.shared.courses.indices {
                // Update the course in a safe way
                CourseViewModel.shared.courses[courseIndex] = CourseViewModel.shared.courses[courseIndex].updatingScheduleTypeName(to: blockName, forScheduleTypeId: scheduleType.id)
            }
            
            // Update the schedule type name in schoolDays (specific days)
            for schoolDayIndex in CourseViewModel.shared.schoolDays.indices {
                if CourseViewModel.shared.schoolDays[schoolDayIndex].dayType.id == scheduleType.id {
                    CourseViewModel.shared.schoolDays[schoolDayIndex].dayType.name = blockName
                }
            }
        }
        NotificationCenter.default.post(name: .didUpdateScheduleTypeFromManager, object: nil)
        dismiss(animated: true)
    }

    // Helper method to update the schedule type name within the course



    // Refresh the available block numbers by removing the already used block numbers
    func refreshAvailableBlockNumbers(editingBlockNumber: Int? = nil) {
        let allBlockNumbers = Array(1...10) // Assume block numbers 1 to 10 are allowed
        let usedBlockNumbers = CourseViewModel.shared.blocksByScheduleType[scheduleType.id]?.map { $0.blockNumber } ?? []

        // If we are editing, add the block number being edited back into the available numbers
        if let editingBlockNumber = editingBlockNumber {
            availableBlockNumbers = allBlockNumbers.filter { $0 == editingBlockNumber || !usedBlockNumbers.contains($0) }
        } else {
            availableBlockNumbers = allBlockNumbers.filter { !usedBlockNumbers.contains($0) }
        }
    }

    // Add a new block using UIPickerView for block number and time selection
    @objc func addBlock() {
        refreshAvailableBlockNumbers() // Update the available block numbers before showing the picker
        let pickerViewController = TimePickerViewController(scheduleType: scheduleType, availableBlockNumbers: availableBlockNumbers)
        pickerViewController.delegate = self
        navigationController?.pushViewController(pickerViewController, animated: true)
    }
}

extension Course {
    func updatingScheduleTypeName(to newName: String, forScheduleTypeId scheduleTypeId: UUID) -> Course {
        var updatedCourse = self
        for dayScheduleIndex in schedule.indices {
            if schedule[dayScheduleIndex].scheduleType.id == scheduleTypeId {
                updatedCourse.schedule[dayScheduleIndex].scheduleType.name = newName
            }
        }
        return updatedCourse
    }
}

// MARK: - TimePickerViewControllerDelegate
extension BlockCustomizationViewController: TimePickerViewControllerDelegate {
    func didAddBlock(block: Block) {
        // Add the block and update the table
        CourseViewModel.shared.addBlock(to: scheduleType, block: block)
        refreshAvailableBlockNumbers()
        tableView.reloadData()
    }

    func didEditBlock(block: Block) {
        // Update the block and refresh the table
        CourseViewModel.shared.updateBlock(in: scheduleType, with: block)
        refreshAvailableBlockNumbers()
        tableView.reloadData()
    }
}

// MARK: - UITableView DataSource & Delegate
extension BlockCustomizationViewController: UITableViewDataSource, UITableViewDelegate {

    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // One section for the text field and another for block list
    }

    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // No rows in the text field section
        } else {
            return CourseViewModel.shared.blocksByScheduleType[scheduleType.id]?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView()
            headerView.backgroundColor = .systemGray6
            
            // Title Label
            let titleLabel = UILabel()
            titleLabel.text = "Blocks"
            titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(titleLabel)
            
            // Add Button
            let addButton = UIButton(type: .system)
            addButton.setTitle("Add Blocks", for: .normal)
            addButton.tintColor = .accent
            addButton.addTarget(self, action: #selector(addBlock), for: .touchUpInside)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(addButton)
            
            // Layout constraints for title and button
            NSLayoutConstraint.activate([
                // Title label constraints
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                
                // Add button constraints
                addButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                addButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ])
            
            return headerView
        }
        return nil
    }

    // Height for section headers
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 28 : 0 // Set header height for second section
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Disable selection for section 0
        if indexPath.section == 0 {
            return nil // Returning nil prevents the row from being selected
        }
        return indexPath // Enable selection for other sections
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Section 0: Schedule Name input field
            let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.textLabel?.text = "Schedule Name:"
            let textField = UITextField(frame: CGRect(x: 150, y: 0, width: 200, height: 44))
            textField.placeholder = "Enter schedule name"
            textField.text = blockName
            textField.tag = 1000
            textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
            cell.contentView.addSubview(textField)
            return cell
        } else {
            // Section 1: Block list or "None" if empty
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlockCell", for: indexPath) as! BlockCustomizationCell
            
            // Fetch blocks for the current scheduleType
            if let blocks = CourseViewModel.shared.blocksByScheduleType[scheduleType.id], !blocks.isEmpty {
                // Sort the blocks by block number
                let sortedBlocks = blocks.sorted { $0.blockNumber < $1.blockNumber }
                let block = sortedBlocks[indexPath.row]
                
                // Configure block information
                if let startTime = CourseViewModel.shared.combineDateAndTime(date: Date(), time: block.startTime),
                   let endTime = CourseViewModel.shared.combineDateAndTime(date: Date(), time: block.endTime) {
                    cell.blockLabel.text = "Block \(block.blockNumber): \(startTime.formattedHMTime()) - \(endTime.formattedHMTime())"
                } else {
                    cell.blockLabel.text = "Block \(block.blockNumber): Time unavailable"
                }
                
            }
            
            return cell
        }
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == 1 {
            // Update your data model first
            
            if let blocks = CourseViewModel.shared.blocksByScheduleType[scheduleType.id], indexPath.row <= blocks.count {
                
                
                CourseViewModel.shared.deleteBlock(from: scheduleType, at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }

            
            // Then, delete the row in the table view
            //tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            // Retrieve the current block number for the selected block
            if let blocks = CourseViewModel.shared.blocksByScheduleType[scheduleType.id]?.sorted(by: { $0.blockNumber < $1.blockNumber }), indexPath.row <= blocks.count {
                let currentBlock = blocks[indexPath.row]
                
                var blockNumbersAvailable = availableBlockNumbers
                blockNumbersAvailable.append(currentBlock.blockNumber)
                blockNumbersAvailable = blockNumbersAvailable.sorted()
                
                // Pass the current block number along with available blocks to the picker view controller
                let pickerViewController = TimePickerViewController(
                    scheduleType: scheduleType,
                    availableBlockNumbers: blockNumbersAvailable, // Include current block number,
                    blockToEdit: currentBlock
                )
                
                pickerViewController.delegate = self
                navigationController?.pushViewController(pickerViewController, animated: true)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            // Check if the list is empty and if "None" is being displayed
            let blocks = CourseViewModel.shared.blocksByScheduleType[scheduleType.id] ?? []
            
            // If there are no blocks, return false to disable editing
            return !blocks.isEmpty
        }
        return false // Disable editing for other sections
    }

    
    @objc func textFieldChanged(_ textField: UITextField) {
        if textField.tag == 1000 {
            blockName = textField.text ?? ""
        }
    }
}

class BlockCustomizationCell: UITableViewCell {
    let blockLabel = UILabel()
    let chevronImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        // Custom view for the cell's content
        let customView = UIView()
        customView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(customView)
        
        // Configure block label
        blockLabel.translatesAutoresizingMaskIntoConstraints = false
        blockLabel.textColor = .label
        blockLabel.font = UIFont.systemFont(ofSize: 16)
        customView.addSubview(blockLabel)
        
        // Configure chevron image view
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right") // Use SF Symbol for chevron
        chevronImageView.tintColor = .gray
        customView.addSubview(chevronImageView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            customView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            customView.topAnchor.constraint(equalTo: contentView.topAnchor),
            customView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            blockLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 16),
            blockLabel.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
            
            chevronImageView.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: customView.centerYAnchor)
        ])
    }
}




class TimePickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate: TimePickerViewControllerDelegate?
    
    var scheduleType: ScheduleType
    var availableBlockNumbers: [Int]
    
    var blockToEdit: Block?
    var blockIndex: Int?
    
    let blockPicker = UIPickerView()
    let startTimePicker = UIDatePicker()
    let endTimePicker = UIDatePicker()
    var pickerStackView = UIStackView()
    
    var selectedBlockNumber: Int?
    var startTime: String = "08:00"
    var endTime: String = "09:00"
    
    
    init(scheduleType: ScheduleType, availableBlockNumbers: [Int], blockToEdit: Block? = nil, blockIndex: Int? = nil) {
        self.scheduleType = scheduleType
        self.availableBlockNumbers = availableBlockNumbers
        
        if let first = availableBlockNumbers.first {
            self.selectedBlockNumber = first
        }
        if let block = blockToEdit {
            startTime = block.startTime
            endTime = block.endTime
        }
        self.blockToEdit = blockToEdit
        self.blockIndex = blockIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureForEditing()
    }
    
    func configureForEditing() {
            if let blockToEdit = blockToEdit {
                selectedBlockNumber = blockToEdit.blockNumber
                startTime = blockToEdit.startTime
                endTime = blockToEdit.endTime
                
                // Set block number picker to the correct value
                if let blockNumberIndex = availableBlockNumbers.firstIndex(of: blockToEdit.blockNumber) {
                    blockPicker.selectRow(blockNumberIndex, inComponent: 0, animated: false)
                }
                
                // Set the time pickers to the block’s current start and end times
                startTimePicker.date = getDate(from: startTime) ?? Date()
                endTimePicker.date = getDate(from: endTime) ?? Date()
            }
        }
    
    func setupUI() {
        title = blockToEdit == nil ? "Pick Block and Time" : "Edit Block"
        view.backgroundColor = .systemBackground
        
        // Setup UIPicker for block number
        blockPicker.delegate = self
        blockPicker.dataSource = self
        blockPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blockPicker)
        
        pickerStackView.translatesAutoresizingMaskIntoConstraints = false
        pickerStackView.axis = .horizontal
        pickerStackView.spacing = 10
        
        
        
        // Setup UIDatePicker for start time selection
        startTimePicker.datePickerMode = .time
        startTimePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
        startTimePicker.translatesAutoresizingMaskIntoConstraints = false
        startTimePicker.date = getDate(from: startTime) ?? Date()
        pickerStackView.addArrangedSubview(startTimePicker)
        
        var toLabel = UILabel()
        toLabel.text = "to"
        pickerStackView.addArrangedSubview(toLabel)
        
        // Setup UIDatePicker for end time selection
        endTimePicker.datePickerMode = .time
        endTimePicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)
        endTimePicker.translatesAutoresizingMaskIntoConstraints = false
        endTimePicker.date = getDate(from: endTime) ?? Date()
        pickerStackView.addArrangedSubview(endTimePicker)
        
        view.addSubview(pickerStackView)
        
        // Add a button to save the block
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save Block", for: .normal)
        saveButton.addTarget(self, action: #selector(saveBlock), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.backgroundColor = .pink
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 8
        saveButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
        
        
        view.addSubview(saveButton)
        
        // Layout UI elements
        NSLayoutConstraint.activate([
            blockPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            blockPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blockPicker.widthAnchor.constraint(equalToConstant: 200),
            blockPicker.heightAnchor.constraint(equalToConstant: 100),
            
            pickerStackView.topAnchor.constraint(equalTo: blockPicker.bottomAnchor, constant: 20),
            pickerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
           
            
            saveButton.topAnchor.constraint(equalTo: pickerStackView.bottomAnchor, constant: 40),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
            
        ])
    }
    
    func setupEditing(for block: Block) {
        selectedBlockNumber = block.blockNumber
        startTime = block.startTime
        endTime = block.endTime
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        // Set picker and time pickers to current values
        if let blockIndex = availableBlockNumbers.firstIndex(of: block.blockNumber) {
            blockPicker.selectRow(blockIndex, inComponent: 0, animated: false)
        }
        startTimePicker.date = formatter.date(from: startTime) ?? Date()
        endTimePicker.date = formatter.date(from: endTime) ?? Date()
    }
    
    // Handle the start time picker change
    @objc func startTimeChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        startTime = formatter.string(from: sender.date)
    }
    
    // Handle the end time picker change
    @objc func endTimeChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        endTime = formatter.string(from: sender.date)
    }
    
    // Save block
    @objc func saveBlock() {
        guard let blockNumber = selectedBlockNumber else {
            let alert = UIAlertController(title: "Error", message: "Please select a block number", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Ensure that the end time is after the start time
        if let startDate = getDate(from: startTime), let endDate = getDate(from: endTime), startDate >= endDate {
            let alert = UIAlertController(title: "Error", message: "End time must be after start time", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let newBlock = Block(id: blockToEdit?.id ?? UUID(), blockNumber: blockNumber, startTime: startTime, endTime: endTime)
        
        if let block = blockToEdit { // Edit mode
            delegate?.didEditBlock(block: newBlock)
        } else { // Add mode
            delegate?.didAddBlock(block: newBlock)
        }
        
        navigationController?.popViewController(animated: true)
    }

    
    // Helper method to convert string time to Date
    func getDate(from timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: timeString)
    }
    
    // MARK: - UIPickerView Delegate & DataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableBlockNumbers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Block \(availableBlockNumbers[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if !availableBlockNumbers.isEmpty {
            selectedBlockNumber = availableBlockNumbers[row]
        }
        
    }
    
    
}
