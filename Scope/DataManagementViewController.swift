//
//  DataManagementViewController.swift
//  Scope
//
//  Created by Ari Reitman on 9/9/24.
//

import UIKit

class DataManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
    }
    
    func style() {
        navigationItem.title = "Data Management"
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func layout() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // One section for the description, another for the buttons
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Only the description in the first section
        } else {
            return 4 // Three buttons in the second section
        }
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0 {
            // Section 1: Description
            cell.textLabel?.text = "Deleting data is irreversible. Proceed with caution."
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .none // Make it non-selectable
        } else {
            // Section 2: Action buttons
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Delete Courses"
                cell.textLabel?.textColor = .systemRed
            case 1:
                cell.textLabel?.text = "Delete Schedule Types"
                cell.textLabel?.textColor = .systemRed
            case 2:
                cell.textLabel?.text = "Delete Schedule"
                cell.textLabel?.textColor = .systemRed
            case 3:
                cell.textLabel?.text = "Delete All Data"
                cell.textLabel?.textColor = .systemRed
            default:
                break
            }
            cell.textLabel?.textAlignment = .left
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                // Handle "Delete User Data"
                confirmDeleteAction(message: "Are you sure you want to delete all courses?", actionType: .deleteCourses)
            case 1:
                // Handle "Delete App Cache"
                confirmDeleteAction(message: "Are you sure you want to delete all schedule types?", actionType: .deleteScheduleTypes)
            case 2:
                // Handle "Delete All Data"
                confirmDeleteAction(message: "Are you sure you want to delete your schedule?", actionType: .deleteCurrentSchedule)
            case 3:
                confirmDeleteAction(message: "Are you sure you want to delete all data?", actionType: .deleteAllData)
            default:
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    enum DeletionAction {
        case deleteCourses
        case deleteScheduleTypes
        case deleteCurrentSchedule
        case deleteAllData
    }
    
    // MARK: - Helper Function for Confirmation
    
    func confirmDeleteAction(message: String, actionType: DeletionAction) {
        let alertController = UIAlertController(title: "Confirm", message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            // Perform deletion based on action type
            switch actionType {
            case .deleteCourses:
                self.deleteAllCourses()
            case .deleteScheduleTypes:
                self.deleteAllScheduleTypes()
            case .deleteCurrentSchedule:
                self.deleteCurrentSchedule()
            case .deleteAllData:
                self.deleteAllData()
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Actions

    func deleteAllCourses() {
        CourseViewModel.shared.deleteAllCourses()
    }

    func deleteAllScheduleTypes() {
        CourseViewModel.shared.deleteAllScheduleTypes()
    }

    func deleteCurrentSchedule() {
        CourseViewModel.shared.deleteCurrentSchedule()
    }

    func deleteAllData() {
        CourseViewModel.shared.deleteAllData()
    }
}


