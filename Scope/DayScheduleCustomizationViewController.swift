//
//  DayScheduleCustomizationViewController.swift
//  Scope
//
//  Created by Ari Reitman on 9/6/24.
//

import UIKit

class DayScheduleCustomizationViewController: UIViewController {

    let viewModel = CourseViewModel.shared
    var tableView = UITableView()
    var daysOfTheWeek: [DaysOfTheWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(onSchoolDaysUpdate), name: .didUpdateSchoolDays, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onSchoolDaysUpdate() {
        self.tableView.reloadData()
    }
    

    func setupUI() {
        title = "Customize Days"
        view.backgroundColor = .systemBackground

        // Setup TableView
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Register UITableViewCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")


        // Layout TableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc func addSpecificDay() {
        let datePickerVC = DatePickerViewController()
        
        // Handle the date selected from the date picker
        datePickerVC.onDateSelected = { [weak self] selectedDate in
            //self?.assignScheduleType(to: selectedDate)
            self?.viewModel.setScheduleType(for: selectedDate, scheduleType: .none)
            self?.tableView.reloadData()
        }
        
        let navigationController = UINavigationController(rootViewController: datePickerVC)
        // Present the view controller as a page sheet
        navigationController.modalPresentationStyle = .pageSheet
        navigationController.sheetPresentationController?.detents = [.medium()] // Half-page presentation
        
        present(navigationController, animated: true)
    }



    // Present an action sheet to assign a schedule to the specific date
    func assignScheduleType(to date: Date) {
        let alert = UIAlertController(title: "Assign Schedule", message: "Choose a schedule for \(formattedDate(date))", preferredStyle: .actionSheet)
        
        for scheduleType in viewModel.scheduleTypes {
            let action = UIAlertAction(title: scheduleType.name, style: .default) { [weak self] _ in
                self?.viewModel.setScheduleType(for: date, scheduleType: scheduleType)
//                self?.tableView.reloadData()
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // Convert string to Date
    func convertStringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: dateString)
    }
    
    // Format date to display in alert
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func formattedDateLong(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"  // Format for Month Day, Year, and Day Name
        return formatter.string(from: date)
    }

}

extension DayScheduleCustomizationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // One section for recurring days, one for specific days
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // Filter out any days that have a specific schedule assigned
            let specificDays = viewModel.schoolDays.filter { $0.date != nil }.map { $0.date }
            let recurringDaysWithoutSpecifics = daysOfTheWeek.filter { day in
//                if let dateForDay = getDateFor(dayOfTheWeek: day) {
//                    return !specificDays.contains { Calendar.current.isDate($0!, inSameDayAs: dateForDay) }
//                }
                return true
            }
            return recurringDaysWithoutSpecifics.count
        } else {
            // Show only specific days (filter out any duplicates)
            return Set(viewModel.schoolDays.compactMap { $0.date }).count
        }
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)
        
        if indexPath.section == 0 {
            // Regular (recurring) schedule - Always show Monday through Friday
            let dayOfTheWeek = daysOfTheWeek[indexPath.row]
            
            // Get the corresponding date for this day of the week (for the current week)
            if let dateForDay = getDateFor(dayOfTheWeek: dayOfTheWeek) {
                // Check if there's a specific override for this day
                let hasSpecificOverride = viewModel.schoolDays.contains { specificDay in
                    if let specificDate = specificDay.date {
                        return Calendar.current.isDate(specificDate, inSameDayAs: dateForDay)
                    }
                    return false
                }
                
                // Retrieve the schedule type for the day
                let scheduleType = viewModel.reccuringScheduleType(on: dateForDay) ?? ScheduleType.none
                
                // Check if the schedule was deleted
                if !viewModel.scheduleTypes.contains(where: { $0.id == scheduleType.id }) {
                    // If the schedule is deleted, set it to "None"
                    cell.textLabel?.text = "\(dayOfTheWeek.capitalizedString()): None"
                } else {
                    // Display the regular schedule day and indicate if there's an override
                    var cellText = "\(dayOfTheWeek.capitalizedString()): \(scheduleType.name)"
                    cell.textLabel?.text = cellText
                }
            } else {
                cell.textLabel?.text = "\(dayOfTheWeek.capitalizedString()): Unknown"
            }
        } else {
            // Specific days with custom schedules
            let specificDays = viewModel.schoolDays.compactMap { $0.date }.sorted(by: { $0 < $1 })
            let specificDay = specificDays[indexPath.row]
            
            let dateString = formattedDateLong(specificDay)
            
            // Get the schedule type for the specific day
            let scheduleType = viewModel.schoolDays.first(where: { schoolDay in
                if let schoolDayDate = schoolDay.date {
                    return Calendar.current.isDate(schoolDayDate, inSameDayAs: specificDay)
                }
                return false
            })?.dayType ?? ScheduleType.none
            
            // Check if the schedule was deleted
            if !viewModel.scheduleTypes.contains(where: { $0.id == scheduleType.id }) {
                cell.textLabel?.text = "\(dateString): None"
            } else {
                cell.textLabel?.text = "\(dateString): \(scheduleType.name)"
            }
        }

        return cell
    }




    func getDateFor(dayOfTheWeek: DaysOfTheWeek) -> Date? {
        // Get today's date
        let today = Date()
        let calendar = Calendar.current
        
        // Get the weekday of today (Sunday = 1, Monday = 2, ..., Saturday = 7)
        let currentWeekday = calendar.component(.weekday, from: today)
        
        // Calculate the difference between the current weekday and the target weekday
        let daysDifference = dayOfTheWeek.rawValue + 1 - currentWeekday
        
        // Add the difference to today's date to get the target date
        return calendar.date(byAdding: .day, value: daysDifference, to: today)
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // Recurring day logic
            let recurringDaysWithOverrides = daysOfTheWeek.map { day -> (DaysOfTheWeek, Bool) in
                if let dateForDay = getDateFor(dayOfTheWeek: day) {
                    // Check if there is a specific override for this day
                    let hasSpecificOverride = viewModel.schoolDays.contains { specificDay in
                        if let specificDate = specificDay.date {
                            return Calendar.current.isDate(specificDate, inSameDayAs: dateForDay)
                        }
                        return false
                    }
                    return (day, hasSpecificOverride)
                } else {
                    return (day, false)
                }
            }

            let dayInfo = recurringDaysWithOverrides[indexPath.row]
            let day = dayInfo.0

            // Present DayTypeSelectionViewController
            let dayTypeSelectionVC = UINavigationController(rootViewController: DayTypeSelectionViewController(isEditting: true, edittingDay: day))
            
            presentHalfSheet(dayTypeSelectionVC)
            
            
        } else {
            // Specific day logic
            let specificDays = Set(viewModel.schoolDays.compactMap { $0.date }).sorted(by: { $0 < $1 })
            let specificDay = specificDays[indexPath.row]

            // Present DayTypeSelectionViewController for the specific date
            let dayTypeSelectionVC = DayTypeSelectionViewController(isEditting: true)
            dayTypeSelectionVC.selectedDate = specificDay // Pass the specific day
            
            let navigationController = UINavigationController(rootViewController: dayTypeSelectionVC)
            
            presentHalfSheet(navigationController)
            
           
        }
    }

    func presentHalfSheet(_ viewController: UIViewController) {
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium()]  // Set to medium or customize the height
            sheet.prefersGrabberVisible = true  // Show grabber handle at the top
        }
        present(viewController, animated: true, completion: nil)
    }

    func assignScheduleType(to day: DaysOfTheWeek) {
        let alert = UIAlertController(title: "Assign Schedule", message: "Choose a schedule for \(day.capitalizedString())", preferredStyle: .actionSheet)
        
        for scheduleType in viewModel.scheduleTypes {
            let action = UIAlertAction(title: scheduleType.name, style: .default) { [weak self] _ in
                self?.viewModel.assignScheduleToRecurringDay(scheduleType, for: day)
                self?.tableView.reloadData()
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create a view for the header
        let headerView = UIView()
        headerView.backgroundColor = .systemGray6

        // Create a label for the title (Regular Schedule/Specific Days)
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        if section == 0 {
            titleLabel.text = "Regular Schedule"
            NSLayoutConstraint.activate([
                // Layout the title label
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),])
            
        } else {
            titleLabel.text = "Specific Days"
            
            // Add a button next to the "Specific Days" title
            let addButton = UIButton(type: .system)
            addButton.setTitle("Add", for: .normal)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.addTarget(self, action: #selector(addSpecificDay), for: .touchUpInside)
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
        }
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28 // Adjust this value for more spacing
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == 1 {
            // Update your data model first
            viewModel.schoolDays.remove(at: indexPath.row)
            
            // Then, delete the row in the table view
            //tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 // Allow editing only for section 1
    }

}

class DatePickerViewController: UIViewController {

    var datePicker = UIDatePicker()
    var onDateSelected: ((Date) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Set up Next button (instead of Done)
        let nextButton = UIButton(type: .system)
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        navigationItem.title = "Select Date"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextButton)
        
        // Configure the date picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc func nextButtonTapped() {
        // Call this method when the user taps the "Next" button
        let selectedDate = datePicker.date
        //onDateSelected?(selectedDate)
        
        // Push the DayTypeSelectionViewController
        let dayTypeSelectionVC = DayTypeSelectionViewController(isEditting: false)
        dayTypeSelectionVC.selectedDate = selectedDate // Pass the selected date to the next VC
        navigationController?.pushViewController(dayTypeSelectionVC, animated: true)
    }
}

class DayTypeSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tableView = UITableView(frame: .zero, style: .insetGrouped)
   // Add your available day types here
    var selectedDate: Date? // The date passed from the DatePickerViewController
    var edittingDay: DaysOfTheWeek?
    var isEditting: Bool
    
    
    init(isEditting: Bool, edittingDay: DaysOfTheWeek? = nil) {
        self.edittingDay = edittingDay
        self.isEditting = isEditting
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Select Day Type"
        
        // Setup TableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Register UITableViewCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayTypeCell")
        
        // Layout TableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CourseViewModel.shared.scheduleTypes.count + (edittingDay != nil ? 1 : 0) // Add an extra row for "None" when editing recurring days
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayTypeCell", for: indexPath)

        if edittingDay != nil && indexPath.row == 0 {
            // If editing a recurring day (edittingDay is not nil), show "None" as the first option
            cell.textLabel?.text = "None"
        } else {
            // Adjust index only if editing and skip the "None" row
            let adjustedIndex = (edittingDay != nil) ? indexPath.row - 1 : indexPath.row
            if adjustedIndex < CourseViewModel.shared.scheduleTypes.count {
                let dayType = CourseViewModel.shared.scheduleTypes[adjustedIndex]
                cell.textLabel?.text = dayType.name
            }
        }

        return cell
    }



    // UITableViewDelegate Method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if edittingDay != nil && indexPath.row == 0 {
            // Handle "None" selection for recurring days
            if let edittingDay = edittingDay {
                CourseViewModel.shared.assignScheduleToRecurringDay(ScheduleType.none, for: edittingDay)
            }
        } else {
            // Adjust the index if "None" is the first option (i.e., if edittingDay is not nil)
            let adjustedIndex = (edittingDay != nil) ? indexPath.row - 1 : indexPath.row
            
            // Make sure adjustedIndex is within the bounds of the scheduleTypes array
            if adjustedIndex >= 0 && adjustedIndex < CourseViewModel.shared.scheduleTypes.count {
                let selectedDayType = CourseViewModel.shared.scheduleTypes[adjustedIndex]
                
                // Handle the schedule assignment
                if let date = selectedDate {
                    CourseViewModel.shared.setScheduleType(for: date, scheduleType: selectedDayType)
                } else if let edittingDay = edittingDay {
                    CourseViewModel.shared.assignScheduleToRecurringDay(selectedDayType, for: edittingDay)
                }
            }
        }
        
        // After selection, dismiss or pop the view controller
        dismiss(animated: true)
    }


}

