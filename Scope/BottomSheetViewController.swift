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
    var topSheetView = UIView()
    var tableView = UITableView()
    var sortedCourses: [Course] = []
    var blurEffectView = UIView()
    var divider = UIView()
    var plusButton = UIButton()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
        

        
        sortedCourses = CourseViewModel.shared.coursesForToday()
        tableView.reloadData()
        self.isModalInPresentation = true
        
        tableView.contentInset.top = 145
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .didUpdateCountdown, object: nil)
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
        
        
        topSheetView.translatesAutoresizingMaskIntoConstraints = false
        topSheetView.backgroundColor = .red
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        
        //let blurEffect = UIBlurEffect(style: .systemThinMaterial) // You can choose .extraLight, .light, .dark, or .regular
        blurEffectView.backgroundColor = .secondarySystemBackground
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
               
        
        
        
        stackView.addArrangedSubview(label)
        
        plusButton.tintColor = .pink
        plusButton.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        stackView.addArrangedSubview(plusButton)
        
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .secondarySystemFill
        
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CourseCell.self, forCellReuseIdentifier: "CourseCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        

        view.addSubview(tableView)
        view.addSubview(topSheetView)
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
            
            topSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        topSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        topSheetView.topAnchor.constraint(equalTo: divider.bottomAnchor),
                        topSheetView.heightAnchor.constraint(equalToConstant: 70),
                        
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

    
    @objc func updateUI(notification: Notification) {
       
        DispatchQueue.main.async {
            if self.sortedCourses != CourseViewModel.shared.coursesForToday() {
                self.sortedCourses = CourseViewModel.shared.coursesForToday()
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    
    func updateUIForHighDetent() {
        
//        topSheetView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
//        topSheetView.frame.origin.y -= topSheetView.frame.height / 2
//        
            UIView.animate(withDuration: 0.2) {
                self.topSheetView.transform.ty = 0
                
                self.tableView.contentInset.top = 115
            }
        }
        
        func updateUIForLowDetent() {
//            
//            topSheetView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
//            topSheetView.frame.origin.y += topSheetView.frame.height / 2
            UIView.animate(withDuration: 0.2, animations: {
                self.topSheetView.transform.ty = -200
                self.tableView.contentInset.top = 45
            }, completion: { completed in
                
            })
             
        }
}

extension BottomSheetViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
            let offsetY = scrollView.contentOffset.y
            
            // Adjust the opacity of the blur effect and divider
            if offsetY <= -35 {
                UIView.animate(withDuration: 0.05) {
                    //self.blurEffectView.layer.opacity = 0
                    //self.divider.layer.opacity = 1
                }
            } else {
                UIView.animate(withDuration: 0.05) {
                    //self.blurEffectView.layer.opacity = 1
                    //self.divider.layer.opacity = 0
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


