//
//  SettingsViewController.swift
//  Scope
//
//  Created by Ari Reitman on 9/8/24.
//

import UIKit

class SettingsViewController: UIViewController {
    let stackView = UIStackView()
    let label = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
    }
    
}

extension SettingsViewController {
    func style() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Settings"
        navigationItem.largeTitleDisplayMode = .automatic
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
    }
    
    func layout() {
        stackView.addArrangedSubview(label)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


