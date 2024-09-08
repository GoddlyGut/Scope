//
//  ScheduleManagerViewController.swift
//  Scope
//
//  Created by Ari Reitman on 9/5/24.
//

import UIKit

protocol TimePickerViewControllerDelegate: AnyObject {
    func didAddBlock(block: Block)
    func didEditBlock(block: Block, at index: Int)
}

class ScheduleManagerViewController: UIViewController {
    
    let viewModel = CourseViewModel.shared
    var tableView = UITableView()
    var closeButton = CloseButtonView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditing))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        
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
                    self.navigationController?.pushViewController(BlockCustomizationViewController(scheduleType: newScheduleType), animated: true)
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

    
    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.scheduleTypes.count
    }
    
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
        scheduleLabel.textColor = .label
        scheduleLabel.font = UIFont.systemFont(ofSize: 16)

        scheduleLabel.text = "\(CourseViewModel.shared.scheduleTypes[indexPath.row].name)"
        
        
        customView.addSubview(scheduleLabel)
        
        // Create the chevron image view
        let chevronImageView = UIImageView()
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right") // Use SF Symbol for chevron
        chevronImageView.tintColor = .gray
        
        customView.addSubview(chevronImageView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            // Custom view layout
            customView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            customView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            customView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            
            // Block label layout
            scheduleLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 16),
            scheduleLabel.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
            
            // Chevron layout
            chevronImageView.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: customView.centerYAnchor)
        ])
        
        return cell
    }

    
    // Handle row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let schedule = viewModel.scheduleTypes[indexPath.row]
        customizeBlocks(for: schedule)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Editing: Delete schedule
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let schedule = viewModel.scheduleTypes[indexPath.row]
            viewModel.deleteScheduleType(id: schedule.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
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
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
    
    init(scheduleType: ScheduleType) {
        self.scheduleType = scheduleType
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
        title = "Customize \(scheduleType.name)"
        view.backgroundColor = .systemBackground
        
        // Setup TableView
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Register UITableViewCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BlockCell")
        
        // Add block button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add Block", style: .plain, target: self, action: #selector(addBlock))
        
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
        dismiss(animated: true)
    }
    
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

extension BlockCustomizationViewController: TimePickerViewControllerDelegate {
    
    func didAddBlock(block: Block) {
        // Add the block and update the table
        CourseViewModel.shared.addBlock(to: scheduleType, block: block)
        
        refreshAvailableBlockNumbers()
        tableView.reloadData()
    }
    
    // Edit an existing block
    func didEditBlock(block: Block, at index: Int) {
        // Update the block and refresh the table
        CourseViewModel.shared.updateBlock(in: scheduleType, at: index, with: block)
        refreshAvailableBlockNumbers()
        tableView.reloadData()
    }
}

// MARK: - UITableView DataSource & Delegate
extension BlockCustomizationViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CourseViewModel.shared.blocksByScheduleType[scheduleType.id]?.count ?? 0
    }
    
    // Cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockCell", for: indexPath)
        if let blocks = CourseViewModel.shared.blocksByScheduleType[scheduleType.id] {
            let block = blocks[indexPath.row]
            cell.textLabel?.text = "Block \(block.blockNumber): \(block.startTime) - \(block.endTime)"
        }
        return cell
    }
    
    // Handle row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CourseViewModel.shared.deleteBlock(from: scheduleType, at: indexPath.row)
            refreshAvailableBlockNumbers()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            guard let self = self, let blocks = CourseViewModel.shared.blocksByScheduleType[self.scheduleType.id] else { return }
            let blockToEdit = blocks[indexPath.row]
            
            // Pass the block number to ensure it's available in the picker
            self.refreshAvailableBlockNumbers(editingBlockNumber: blockToEdit.blockNumber)
            
            let pickerViewController = TimePickerViewController(scheduleType: self.scheduleType, availableBlockNumbers: self.availableBlockNumbers, blockToEdit: blockToEdit, blockIndex: indexPath.row)
            pickerViewController.delegate = self
            self.navigationController?.pushViewController(pickerViewController, animated: true)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            CourseViewModel.shared.deleteBlock(from: self?.scheduleType ?? ScheduleType.none, at: indexPath.row)
            self?.refreshAvailableBlockNumbers()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
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
    
    var selectedBlockNumber: Int?
    var startTime: String = "08:00"
    var endTime: String = "09:00"
    
    
    init(scheduleType: ScheduleType, availableBlockNumbers: [Int], blockToEdit: Block? = nil, blockIndex: Int? = nil) {
        self.scheduleType = scheduleType
        self.availableBlockNumbers = availableBlockNumbers
        
        if let first = availableBlockNumbers.first {
            self.selectedBlockNumber = first
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
        
        // Setup UIDatePicker for start time selection
        startTimePicker.datePickerMode = .time
        startTimePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
        startTimePicker.translatesAutoresizingMaskIntoConstraints = false
        startTimePicker.date = getDate(from: startTime) ?? Date()
        view.addSubview(startTimePicker)
        
        // Setup UIDatePicker for end time selection
        endTimePicker.datePickerMode = .time
        endTimePicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)
        endTimePicker.translatesAutoresizingMaskIntoConstraints = false
        endTimePicker.date = getDate(from: endTime) ?? Date()
        view.addSubview(endTimePicker)
        
        // Add a button to save the block
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save Block", for: .normal)
        saveButton.addTarget(self, action: #selector(saveBlock), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        // Layout UI elements
        NSLayoutConstraint.activate([
            blockPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            blockPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blockPicker.widthAnchor.constraint(equalToConstant: 200),
            blockPicker.heightAnchor.constraint(equalToConstant: 100),
            
            startTimePicker.topAnchor.constraint(equalTo: blockPicker.bottomAnchor, constant: 20),
            startTimePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            endTimePicker.topAnchor.constraint(equalTo: startTimePicker.bottomAnchor, constant: 20),
            endTimePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            saveButton.topAnchor.constraint(equalTo: endTimePicker.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
        
        let newBlock = Block(blockNumber: blockNumber, startTime: startTime, endTime: endTime)
        
        if let blockIndex = blockIndex { // Edit mode
            delegate?.didEditBlock(block: newBlock, at: blockIndex)
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
