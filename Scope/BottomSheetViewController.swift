//
//  BottomSheetViewController.swift
//  Scope
//
//  Created by Ari Reitman on 6/24/24.
//


import UIKit

class BottomSheetViewController: UIViewController, UITableViewDataSource {
    let stackView = UIStackView()
    let label = UILabel()
    var tableView = UITableView()
    var sortedCourses: [Course] = []
    var blurEffectView = UIVisualEffectView()
    var divider = UIView()
    var plusButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
        
        sortedCourses = CourseViewModel.shared.coursesForToday()
        tableView.reloadData()
        self.isModalInPresentation = true
        
        tableView.contentInset.top = 45
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
    }
    
    override func viewDidLayoutSubviews() {
        
        
        
    }
}

extension BottomSheetViewController {
    func style() {
        self.title = "Schedule"
        view.backgroundColor = .systemBackground
        
        
        label.text = "Courses"
        label.font = .systemFont(ofSize: 20.0, weight: .bold)
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterial) // You can choose .extraLight, .light, .dark, or .regular
                blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        
        stackView.addArrangedSubview(label)
        
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        stackView.addArrangedSubview(plusButton)
        
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .secondarySystemFill
        
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CourseCell.self, forCellReuseIdentifier: "CourseCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        
        view.addSubview(tableView)
        view.addSubview(blurEffectView)
        view.addSubview(stackView)
        view.addSubview(divider)

            
        
        
    }
    
    func layout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 45),
            divider.heightAnchor.constraint(equalToConstant: 0.5),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            blurEffectView.heightAnchor.constraint(equalTo: stackView.heightAnchor),
        ])
    }
    
    
    func updateUIForHighDetent() {
        label.text = "Test"
    }
    func updateUIForLowDetent() {
        label.text = "Courses"
    }
}

extension BottomSheetViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -35 {
            UIView.animate(withDuration: 0.05) {
                self.blurEffectView.layer.opacity = 0
                self.divider.layer.opacity = 1
            }
            
        }
        else {
            UIView.animate(withDuration: 0.05) {
                self.blurEffectView.layer.opacity = 1
                self.divider.layer.opacity = 0
            }
        }
        print(tableView.contentOffset)
    }
}

extension BottomSheetViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortedCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as? CourseCell else {
            return UITableViewCell()
        }
            
        let course = sortedCourses[indexPath.row]
        cell.configure(with: course)
        
        return cell
    }
}


