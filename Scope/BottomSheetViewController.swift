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
    var sortedCourseBlocks: [(course: Course, block: Block, dayType: ScheduleType)] = []
    var blurEffectView = UIView()
    var divider = UIView()
    var plusButton = UIButton()
    var settingsButton = UIButton()
    var daysButton = UIButton()
    
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
    
    
    var nothingStackView = UIStackView()
    var nothingImageView = UIImageView()
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
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: .didUpdateBlocks, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: .didUpdateCourseList, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
       // totalProgressBar.layer.cornerRadius = totalProgressBar.frame.height / 2
       
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    
}

extension BottomSheetViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return TabSheetPresentationController(presentedViewController: presented, presenting: presenting)
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
        currentCourseNameLabel.text = CourseViewModel.shared.currentCourse()?.course.name ?? "Unknown"
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
        
        plusButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysTemplate), for: .normal)
        plusButton.addTarget(self, action: #selector(createNewCourse), for: .touchUpInside)
        
        
        var subStackView = UIStackView()
        
        subStackView.axis = .horizontal
        subStackView.alignment = .trailing
        subStackView.spacing = 15
        subStackView.backgroundColor = .clear
        
        subStackView.addArrangedSubview(plusButton)
        
        settingsButton.tintColor = .pink
        
        settingsButton.setImage(UIImage(systemName: "gear", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysTemplate), for: .normal)
        //plusButton.addTarget(self, action: #selector(createNewCourse), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        subStackView.addArrangedSubview(settingsButton)
        
        daysButton.tintColor = .pink
        
        daysButton.setImage(UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysTemplate), for: .normal)
        //plusButton.addTarget(self, action: #selector(createNewCourse), for: .touchUpInside)
        daysButton.addTarget(self, action: #selector(daysButtonPressed), for: .touchUpInside)
        subStackView.addArrangedSubview(daysButton)
 
        
        stackView.addArrangedSubview(subStackView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CourseCell.self, forCellReuseIdentifier: "CourseCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        

        view.addSubview(tableView)
        view.addSubview(topSheetView)
        view.addSubview(blurEffectView)
        view.addSubview(stackView)
        
        
        nothingStackView.translatesAutoresizingMaskIntoConstraints = false
        nothingStackView.axis = .vertical
        nothingStackView.alignment = .center
        nothingStackView.spacing = 20
        nothingStackView.isHidden = !CourseViewModel.shared.coursesForToday().isEmpty
        
        nothingImageView.image = UIImage(systemName: "tray.fill")
        nothingImageView.translatesAutoresizingMaskIntoConstraints = false
        nothingStackView.addArrangedSubview(nothingImageView)
        
        var nothingLabel = UILabel()
        nothingLabel.text = "No courses"
        nothingLabel.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .headline), size: 23)
        nothingStackView.addArrangedSubview(nothingLabel)
        
        view.addSubview(nothingStackView)
        
        
    }
    
    @objc func settingsButtonPressed() {
        present(UINavigationController(rootViewController: ScheduleManagerViewController()), animated: true)
    }
    
    @objc func daysButtonPressed() {
        present(UINavigationController(rootViewController: DayScheduleCustomizationViewController()), animated: true)
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
                        
            nothingStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            nothingStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nothingImageView.widthAnchor.constraint(equalToConstant: 80),
            nothingImageView.heightAnchor.constraint(equalToConstant: 80),
            
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

            
            currentCourseVerticalStackView.centerYAnchor.constraint(equalTo: currentCourseProgress.centerYAnchor),
            
            clockImageView.centerXAnchor.constraint(equalTo: currentCourseProgress.centerXAnchor),
            clockImageView.centerYAnchor.constraint(equalTo: currentCourseProgress.centerYAnchor),
            
            clockImageView.widthAnchor.constraint(equalToConstant: 20),
            clockImageView.heightAnchor.constraint(equalToConstant: 20),
          
        ])
        
        
    }
    
    @objc func createNewCourse() {
        let vc = FullCourseListViewController()
        //vc.modalPresentationStyle = .fullScreen
        present(UINavigationController(rootViewController: vc), animated: true)
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
    func areCourseBlocksEqual(_ lhs: [(course: Course, block: Block, dayType: ScheduleType)],
                              _ rhs: [(course: Course, block: Block, dayType: ScheduleType)]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (index, leftElement) in lhs.enumerated() {
            let rightElement = rhs[index]
            if leftElement.course != rightElement.course ||
               leftElement.block.blockNumber != rightElement.block.blockNumber ||
                leftElement.dayType != rightElement.dayType {
                return false
            }
        }
        return true
    }

    
    @objc func reloadTable(notification: Notification) {
        
        let sortedCourseBlocksForToday = CourseViewModel.shared.coursesForToday()
        self.sortedCourseBlocks = sortedCourseBlocksForToday
        self.tableView.reloadData()
    }
    
    @objc func updateUI(notification: Notification) {
       
        DispatchQueue.main.async {
            
            self.nothingStackView.isHidden = !CourseViewModel.shared.coursesForToday().isEmpty
            self.updateProgressRing()
            let sortedCourseBlocksForToday = CourseViewModel.shared.coursesForToday()
            if !self.areCourseBlocksEqual(self.sortedCourseBlocks, sortedCourseBlocksForToday) {
                self.sortedCourseBlocks = sortedCourseBlocksForToday
                self.tableView.reloadData()
            }
            
        }
        
        
        
        currentCourseNameLabel.text = CourseViewModel.shared.currentCourse()?.course.name ?? "Unknown"
        
         
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
            
            let (course, block, dayType) = sortedCourseBlocks[indexPath.row]
            cell.configure(with: course, block: block, dayType: dayType)
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let (course, block, dayType) = sortedCourseBlocks[indexPath.row]
            present(UINavigationController(rootViewController: FullCourseListViewController()), animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    
    
}


