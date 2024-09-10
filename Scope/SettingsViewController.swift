//
//  SettingsViewController.swift
//  Scope
//
//  Created by Ari Reitman on 9/8/24.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let settingsOptions = ["Schedule Types", "Schedule", "Data"]
    var closeButton = CloseButtonView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
        setupTableView()
        
    }
    
    func style() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Settings"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        closeButton.circle.addTarget(self, action: #selector(closeSettings), for: .touchUpInside)
    }
    
    @objc func closeSettings() {
        dismiss(animated: true)
    }
    
    func layout() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
    
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        let option = settingsOptions[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.iconImageView.image = UIImage(systemName: "list.clipboard") // Use your desired icons
            cell.titleLabel.text = option
            cell.iconContainerView.backgroundColor = .systemGray
        case 1:
            cell.iconImageView.image = UIImage(systemName: "calendar") // Use your desired icons
            cell.titleLabel.text = option
            cell.iconContainerView.backgroundColor = .systemRed
        case 2:
            cell.iconImageView.image = UIImage(systemName: "externaldrive.fill") // Use your desired icons
            cell.titleLabel.text = option
            cell.iconContainerView.backgroundColor = .systemBlue
            
        default:
            cell.iconImageView.image = UIImage(systemName: "") // Use your desired icons
            cell.titleLabel.text = option
            cell.iconContainerView.backgroundColor = .systemBlue
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let viewController = ScheduleManagerViewController ()
            navigationController?.pushViewController(viewController, animated: true)
        case 1:
            let viewController = DayScheduleCustomizationViewController()
            navigationController?.pushViewController(viewController, animated: true)
        case 2:
            let viewController = DataManagementViewController()
            navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }
}
class SettingsCell: UITableViewCell {

    let iconContainerView = UIView()
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        // Icon container view to resemble a rounded square
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
         // Background color for icon container
        iconContainerView.layer.cornerRadius = 8
        iconContainerView.clipsToBounds = true
        
        // Icon image view inside the container
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white // Set icon color (adjust as needed)
        
        // Title label for the setting name
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        // Chevron image on the right
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.tintColor = .gray
        
        // Add subviews
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(chevronImageView)
    }
    
    func layoutViews() {
        NSLayoutConstraint.activate([
            // Icon container (round square)
            iconContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 30), // Adjust size of the round square
            iconContainerView.heightAnchor.constraint(equalToConstant: 30),
            
            // Icon inside the container
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 17), // Adjust icon size
            iconImageView.heightAnchor.constraint(equalToConstant: 17),
            
            // Title label (Setting name)
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Chevron on the right
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
        ])
    }
}
