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
    var sortedCourseBlocks: [(course: Course, block: Block, day: DaysOfTheWeek)] = []
    var blurEffectView = UIView()
    var divider = UIView()
    var plusButton = UIButton()
    
    var delegate: BottomSheetDelegate?
    

    var currentCourseStackView = UIStackView()
    
    var currentCourseVerticalStackView = UIStackView()
    var currentCourseLabel = UILabel()
    
    var clockImageView = UIButton()
    var currentCourseProgress = ProgressRingView()
    var currentCourseNameLabel = UILabel()
    var isFullyShown = false
    
    var stackViewHeight: CGFloat = 45.0
    var topSheetHeight: CGFloat = 70.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
        

        
        sortedCourseBlocks = CourseViewModel.shared.coursesForToday()
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
       // totalProgressBar.layer.cornerRadius = totalProgressBar.frame.height / 2
       
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension BottomSheetViewController {
    func style() {

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
            stackView.heightAnchor.constraint(equalToConstant: stackViewHeight),
            
            topSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        topSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        topSheetView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
                        topSheetView.heightAnchor.constraint(equalToConstant: topSheetHeight),
                        
            
            
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
            
            
    
            
        
            
            currentCourseProgress.widthAnchor.constraint(equalToConstant: 40),
            currentCourseProgress.heightAnchor.constraint(equalToConstant: 40),
            
            currentCourseVerticalStackView.centerYAnchor.constraint(equalTo: currentCourseProgress.centerYAnchor),
            
            clockImageView.centerXAnchor.constraint(equalTo: currentCourseProgress.centerXAnchor),
            clockImageView.centerYAnchor.constraint(equalTo: currentCourseProgress.centerYAnchor),
            
            clockImageView.widthAnchor.constraint(equalToConstant: 20),
            clockImageView.heightAnchor.constraint(equalToConstant: 20),
          
        ])
        
        
    }

    
    func updateProgressRing() {
            guard let event = CourseViewModel.shared.currentOrNextCourse() else {
                currentCourseProgress.setProgress(to: 0, withAnimation: true)
                return
            }
            
            let now = Date()
            let totalTime: TimeInterval
            let elapsedTime: TimeInterval
            
            if event.isOngoing {
                totalTime = event.endTime.timeIntervalSince(event.startTime)
                elapsedTime = now.timeIntervalSince(event.startTime)
            } else {
                totalTime = event.startTime.timeIntervalSince(now)
                elapsedTime = 0
            }
            
            let progress = elapsedTime / totalTime
            currentCourseProgress.setProgress(to: CGFloat(progress), withAnimation: true)
        }
    func areCourseBlocksEqual(_ lhs: [(course: Course, block: Block, day: DaysOfTheWeek)],
                              _ rhs: [(course: Course, block: Block, day: DaysOfTheWeek)]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (index, leftElement) in lhs.enumerated() {
            let rightElement = rhs[index]
            if leftElement.course != rightElement.course ||
               leftElement.block.blockNumber != rightElement.block.blockNumber ||
               leftElement.day != rightElement.day {
                return false
            }
        }
        return true
    }

    
    @objc func updateUI(notification: Notification) {
       
        DispatchQueue.main.async {
            self.updateProgressRing()
            let sortedCourseBlocksForToday = CourseViewModel.shared.coursesForToday()
            if !self.areCourseBlocksEqual(self.sortedCourseBlocks, sortedCourseBlocksForToday) {
                self.sortedCourseBlocks = sortedCourseBlocksForToday
                self.tableView.reloadData()
            }
            
        }
        
        currentCourseNameLabel.text = CourseViewModel.shared.currentCourse()?.name ?? "Unknown"
        
         
        if CourseViewModel.shared.currentCourse() == nil {
            if self.topSheetView.transform.ty != -topSheetHeight {
                UIView.animate(withDuration: 0.15) {
                    self.topSheetView.transform.ty = -self.topSheetHeight
                    self.tableView.contentInset.top = self.stackViewHeight
                }
            }
            
        }
        else {
            
            if self.topSheetView.transform.ty != 0 && isFullyShown {
                UIView.animate(withDuration: 0.2) {
                    self.topSheetView.transform.ty = 0
                    self.tableView.contentInset.top = 115
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
                
                self.tableView.contentInset.top = self.topSheetHeight + self.stackViewHeight
            }
        }
    }
        
        func updateUIForLowDetent() {
//            
//            topSheetView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
//            topSheetView.frame.origin.y += topSheetView.frame.height / 2
            UIView.animate(withDuration: 0.15) {
                self.topSheetView.transform.ty = -self.topSheetHeight
                self.tableView.contentInset.top = self.stackViewHeight
            }
             
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
            return sortedCourseBlocks.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as? CourseCell else {
                return UITableViewCell()
            }
            
            let (course, block, day) = sortedCourseBlocks[indexPath.row]
            cell.configure(with: course, block: block, day: day)
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let (course, block, day) = sortedCourseBlocks[indexPath.row]
            present(CourseInfoViewController(course: course, block: block, day: day), animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    
    
}


