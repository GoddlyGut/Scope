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
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Register UITableViewCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")

        // Add button to set schedule for specific dates
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Specific Day", style: .plain, target: self, action: #selector(addSpecificDay))

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
                    if hasSpecificOverride {
                        cellText += " (Override Exists)"
                    }
                    cell.textLabel?.text = cellText
                }
            } else {
                cell.textLabel?.text = "\(dayOfTheWeek.capitalizedString()): Unknown"
            }
        } else {
            // Specific days with custom schedules
            let specificDays = viewModel.schoolDays.compactMap { $0.date }.sorted(by: { $0 < $1 })
            let specificDay = specificDays[indexPath.row]
            
            let dateString = formattedDate(specificDay)
            
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

            // Show options to assign schedule, set to none, or delete
            let alert = UIAlertController(title: "Day Options", message: "What would you like to do?", preferredStyle: .actionSheet)

            // Assign schedule
            alert.addAction(UIAlertAction(title: "Assign Schedule", style: .default) { _ in
                self.assignScheduleType(to: day)
            })

            // Set to None
            alert.addAction(UIAlertAction(title: "Set to None", style: .destructive) { _ in
                self.viewModel.assignScheduleToRecurringDay(ScheduleType.none, for: day)
                tableView.reloadData()
            })

            // Cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            present(alert, animated: true)
        } else {
            // Specific day logic
            let specificDays = Set(viewModel.schoolDays.compactMap { $0.date }).sorted(by: { $0 < $1 })
            let specificDay = specificDays[indexPath.row]

            let alert = UIAlertController(title: "Day Options", message: "What would you like to do?", preferredStyle: .actionSheet)

            // Assign schedule
            alert.addAction(UIAlertAction(title: "Assign Schedule", style: .default) { _ in
                self.assignScheduleType(to: specificDay)
            })

            // Delete specific day
            alert.addAction(UIAlertAction(title: "Delete Day", style: .destructive) { _ in
                if let index = self.viewModel.schoolDays.firstIndex(where: { $0.date == specificDay }) {
                    self.viewModel.schoolDays.remove(at: index)
                    tableView.reloadData()
                }
            })

            // Cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            present(alert, animated: true)
        }
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Regular Schedule" : "Specific Days"
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
        onDateSelected?(selectedDate)
        
        // Push the DayTypeSelectionViewController
        let dayTypeSelectionVC = DayTypeSelectionViewController()
        dayTypeSelectionVC.selectedDate = selectedDate // Pass the selected date to the next VC
        navigationController?.pushViewController(dayTypeSelectionVC, animated: true)
    }
}

class DayTypeSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tableView = UITableView()
   // Add your available day types here
    var selectedDate: Date? // The date passed from the DatePickerViewController

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
        return CourseViewModel.shared.scheduleTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayTypeCell", for: indexPath)
        let dayType = CourseViewModel.shared.scheduleTypes[indexPath.row]
        cell.textLabel?.text = dayType.name
        return cell
    }

    // UITableViewDelegate Method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDayType = CourseViewModel.shared.scheduleTypes[indexPath.row]
        
        // Here, you can do whatever you need with the selected day type and the selected date
        if let date = selectedDate {
            print("Selected date: \(date), Selected day type: \(selectedDayType.name)")
            CourseViewModel.shared.setScheduleType(for: date, scheduleType: selectedDayType)
            // For example, you can assign the selected day type to the selected date
            // (This depends on your view model logic)
        }
        
        // After selection, you can pop or navigate away
        dismiss(animated: true)
    }
}

