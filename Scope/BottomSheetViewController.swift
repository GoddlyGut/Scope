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
    

    var currentCourseStackView = UIStackView()
    
    var currentCourseVerticalStackView = UIStackView()
    var currentCourseLabel = UILabel()
    
    var clockImageView = UIButton()
    var currentCourseProgress = ProgressRingView()
    var currentCourseNameLabel = UILabel()
    var currentCoursePercentDone = UILabel()
    var totalProgressBar = UIView()
    var totalProgressLabel = UILabel()
    var isFullyShown = false
    
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .didUpdateCountdown, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        totalProgressBar.layer.cornerRadius = totalProgressBar.frame.height / 2
       
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension BottomSheetViewController {
    func style() {
        self.title = "Schedule"
        view.backgroundColor = .systemBackground
        
        
        label.text = "Courses"
        label.font = .systemFont(ofSize: 20.0, weight: .bold)
        
        
        topSheetView.translatesAutoresizingMaskIntoConstraints = false
        topSheetView.backgroundColor = .secondarySystemBackground
        topSheetView.transform.ty = -200
        
        
        currentCourseStackView.translatesAutoresizingMaskIntoConstraints = false
        currentCourseStackView.axis = .horizontal
        currentCourseStackView.alignment = .leading
        currentCourseStackView.spacing = 17
        
        topSheetView.addSubview(currentCourseStackView)
        
        
        totalProgressBar.translatesAutoresizingMaskIntoConstraints = false
        totalProgressBar.backgroundColor = .secondarySystemFill
        topSheetView.addSubview(totalProgressBar)
        
        totalProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        totalProgressLabel.text = "50% Done"
        totalProgressLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        totalProgressLabel.textColor = .white
        view.addSubview(totalProgressLabel)
        
        currentCourseProgress.translatesAutoresizingMaskIntoConstraints = false
        currentCourseProgress.lineWidth = 5
        currentCourseProgress.setProgress(to: 0.5, withAnimation: true)
        currentCourseStackView.addArrangedSubview(currentCourseProgress)
        
        clockImageView.translatesAutoresizingMaskIntoConstraints = false
//        clockImageView.setImage(UIImage(systemName: "stopwatch.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
//        clockImageView.setImage(UIImage(systemName: "stopwatch.fill")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
//        clockImageView.tintColor = .pink
        
        
        
        currentCourseProgress.addSubview(clockImageView)
        
        currentCourseVerticalStackView.axis = .vertical
        currentCourseVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
        currentCourseVerticalStackView.alignment = .leading
        
        
        currentCourseLabel.text = "Current course"
        currentCourseLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        currentCourseVerticalStackView.addArrangedSubview(currentCourseLabel)
        
        currentCourseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        currentCourseNameLabel.text = CourseViewModel.shared.currentCourse()?.name ?? "Unknown"
        currentCourseNameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        
        
        
        currentCourseVerticalStackView.addArrangedSubview(currentCourseNameLabel)
        
        currentCourseStackView.addArrangedSubview(currentCourseVerticalStackView)
        
        currentCoursePercentDone.translatesAutoresizingMaskIntoConstraints = false
        currentCoursePercentDone.font = .systemFont(ofSize: 20, weight: .semibold)
        currentCoursePercentDone.text = "50% 😵‍💫"
        
        topSheetView.addSubview(currentCoursePercentDone)
        
        //currentCourseStackView.addArrangedSubview(currentCourseIcon)
        
        
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
 
        
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CourseCell.self, forCellReuseIdentifier: "CourseCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        

        view.addSubview(tableView)
        view.addSubview(topSheetView)
        view.addSubview(blurEffectView)
        view.addSubview(stackView)
        
        
        
        
        
    }
    
    func layout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 45),
            
            topSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        topSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        topSheetView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
                        topSheetView.heightAnchor.constraint(equalToConstant: 100),
                        
            
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            blurEffectView.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            
            
            currentCourseStackView.leadingAnchor.constraint(equalTo: topSheetView.leadingAnchor, constant: 20),
            currentCourseStackView.topAnchor.constraint(equalTo: topSheetView.topAnchor, constant: 10),
            
            
            
            totalProgressBar.leadingAnchor.constraint(equalTo: topSheetView.leadingAnchor, constant: 15),
            totalProgressBar.bottomAnchor.constraint(equalTo: topSheetView.bottomAnchor, constant: -15),
            totalProgressBar.trailingAnchor.constraint(equalTo: topSheetView.trailingAnchor, constant: -15),
            totalProgressBar.heightAnchor.constraint(equalToConstant: 15),
            
            totalProgressLabel.bottomAnchor.constraint(equalTo: totalProgressBar.topAnchor, constant: 3),
            totalProgressLabel.trailingAnchor.constraint(equalTo: totalProgressBar.trailingAnchor, constant: 3),
            totalProgressLabel.leadingAnchor.constraint(equalTo: totalProgressBar.centerXAnchor),
            totalProgressLabel.heightAnchor.constraint(equalToConstant: 10),
            
        
            
            currentCourseProgress.widthAnchor.constraint(equalToConstant: 40),
            currentCourseProgress.heightAnchor.constraint(equalToConstant: 40),
            
            currentCourseVerticalStackView.centerYAnchor.constraint(equalTo: currentCourseProgress.centerYAnchor),
            
            clockImageView.centerXAnchor.constraint(equalTo: currentCourseProgress.centerXAnchor),
            clockImageView.centerYAnchor.constraint(equalTo: currentCourseProgress.centerYAnchor),
            
            clockImageView.widthAnchor.constraint(equalToConstant: 20),
            clockImageView.heightAnchor.constraint(equalToConstant: 20),
            
            currentCoursePercentDone.trailingAnchor.constraint(equalTo: topSheetView.trailingAnchor, constant: -20),
            currentCoursePercentDone.centerYAnchor.constraint(equalTo: currentCourseStackView.centerYAnchor),
        ])
        
        
    }

    
    @objc func updateUI(notification: Notification) {
       
        DispatchQueue.main.async {
            if self.sortedCourses != CourseViewModel.shared.coursesForToday() {
                self.sortedCourses = CourseViewModel.shared.coursesForToday()
                self.tableView.reloadData()
            }
            
        }
        
         
        if CourseViewModel.shared.currentCourse() == nil {
            if self.topSheetView.transform.ty != -200 {
                UIView.animate(withDuration: 0.15) {
                    self.topSheetView.transform.ty = -70
                    self.tableView.contentInset.top = 75
                }
            }
            
        }
        else {
            
            if self.topSheetView.transform.ty != 0 && isFullyShown {
                UIView.animate(withDuration: 0.2) {
                    self.topSheetView.transform.ty = 0
                    self.tableView.contentInset.top = 145
                }
            }
        }
    }
    
    
    func updateUIForHighDetent() {
        
        //        topSheetView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        //        topSheetView.frame.origin.y -= topSheetView.frame.height / 2
        //
        if CourseViewModel.shared.currentCourse() != nil {
            UIView.animate(withDuration: 0.2) {
                self.topSheetView.transform.ty = 0
                
                self.tableView.contentInset.top = 145
            }
        }
    }
        
        func updateUIForLowDetent() {
//            
//            topSheetView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
//            topSheetView.frame.origin.y += topSheetView.frame.height / 2
            UIView.animate(withDuration: 0.15, animations: {
                self.topSheetView.transform.ty = -70
                self.tableView.contentInset.top = 75
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


