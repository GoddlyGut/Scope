//
//  ViewController.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import UIKit

class ViewController: UIViewController {

    

    var centerStackView = UIStackView()
    var topLabel = UILabel()
    var currentCourseLabel = UILabel()
    var timeRemaining = UILabel()
    var noCoursesLeft = UILabel()
    var classNameCapsule = UIStackView()
    var classNameLabel = UILabel()
    var classLengthLabel = UILabel()
    
    
    private var progressRing = ProgressRingView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()

        presentSheet()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .didUpdateCountdown, object: nil)
        
    
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        classNameCapsule.layer.cornerRadius = classNameCapsule.frame.height / 2
    }
    
    func onClosure() {
        
            self.presentSheet()
           
        
    }
}

extension ViewController {
    func style() {
        
//        var titleStackView = UIStackView()
//        titleStackView.axis = .vertical
//        titleStackView.alignment = .center
//        
//        var titleLabel = UILabel()
//        titleLabel.text = "Math"
//        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
//        titleStackView.addArrangedSubview(titleLabel)
//        
//        var subtitleLabel = UILabel()
//        subtitleLabel.text = "1:00AM-10:00AM"
//        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
//        titleStackView.addArrangedSubview(subtitleLabel)


        self.navigationItem.title = ""

        
        view.backgroundColor = .systemBackground
        
        centerStackView.translatesAutoresizingMaskIntoConstraints = false
        centerStackView.axis = .vertical
        centerStackView.alignment = .center
        centerStackView.spacing = 4
        
        topLabel.text = ""
        topLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        centerStackView.addArrangedSubview(topLabel)
        
        
        
        timeRemaining.font = UIFont.systemFont(ofSize: 40, weight: .black)
        timeRemaining.isHidden = true
        timeRemaining.textAlignment = .center
        centerStackView.addArrangedSubview(timeRemaining)
        
        
        noCoursesLeft.font = UIFont.systemFont(ofSize: 33, weight: .black)
        noCoursesLeft.numberOfLines = 0
        noCoursesLeft.textAlignment = .center
        noCoursesLeft.text = "No courses\nleft today"
        noCoursesLeft.isHidden = true
        centerStackView.addArrangedSubview(noCoursesLeft)
        
        currentCourseLabel.text = CourseViewModel.shared.currentCourse()?.course.name
        currentCourseLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        
        //centerStackView.addArrangedSubview(currentCourseLabel)
        
        
        view.addSubview(centerStackView)
        
        progressRing.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(progressRing)
        
        classNameCapsule.translatesAutoresizingMaskIntoConstraints = false

        classNameCapsule.axis = .vertical
        classNameCapsule.alignment = .center
        classNameCapsule.isHidden = true
        classNameCapsule.backgroundColor = .secondarySystemBackground
        
        
        classNameLabel.translatesAutoresizingMaskIntoConstraints = false
        classNameLabel.text = "Math"
        classNameLabel.font = .systemFont(ofSize: 21, weight: .bold)
        //classNameCapsule.addArrangedSubview(classNameLabel)
        
        classLengthLabel.translatesAutoresizingMaskIntoConstraints = false
        classLengthLabel.text = "1:00AM-10:00AM"
        classLengthLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        classNameCapsule.addArrangedSubview(classLengthLabel)
        
        progressRing.addSubview(classNameCapsule)
        
    }
    

    
    func layout() {
        NSLayoutConstraint.activate([
            centerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            progressRing.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
                        progressRing.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressRing.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
                        progressRing.heightAnchor.constraint(equalTo: progressRing.widthAnchor),
            centerStackView.centerYAnchor.constraint(equalTo: progressRing.centerYAnchor),
            
            classNameCapsule.centerXAnchor.constraint(equalTo: progressRing.centerXAnchor),
            classNameCapsule.leadingAnchor.constraint(equalTo: classLengthLabel.leadingAnchor, constant: -13),
            classNameCapsule.trailingAnchor.constraint(equalTo: classLengthLabel.trailingAnchor, constant: 13),
            classNameCapsule.topAnchor.constraint(equalTo: centerStackView.bottomAnchor, constant: 15),
            classNameCapsule.heightAnchor.constraint(equalToConstant: 25),
            
            
        ])
    }
    

    @objc private func presentSheet() {
        let sheetViewController = BottomSheetViewController()
            //sheetViewController.modalPresentationStyle = .pageSheet
        sheetViewController.delegate = self
            
            if let sheet = sheetViewController.sheetPresentationController {
                
                let customHighDetent = UISheetPresentationController.Detent.custom(identifier: UISheetPresentationController.Detent.Identifier("highDetent")) { context in
                    return context.maximumDetentValue - 0.3
                }
                
                let customLowDetent = UISheetPresentationController.Detent.custom(identifier: UISheetPresentationController.Detent.Identifier("lowDetent")) { context in
                    return self.view.frame.height * 0.37
                }

                
                sheet.detents = [customLowDetent, customHighDetent]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.largestUndimmedDetentIdentifier = customHighDetent.identifier
                sheet.delegate = self
                
               
            }
        
            present(sheetViewController, animated: true, completion: nil)
        }
    
    
    
    
    @objc func updateUI(notification: Notification) {
       
        
        DispatchQueue.main.async {
            self.updateProgressRing()
            
            
//            if let name = CourseViewModel.shared.currentCourse()?.name {
//                self.classNameCapsule.isHidden = false
//                //self.classNameLabel.text =
//                //CourseViewModel.shared.currentCourse()?.name ?? ""
//            }
//            else {
//                self.classNameCapsule.isHidden = true
//            }
            
            
            
            
            
            
            if CourseViewModel.shared.currentOrNextCourse() == nil {
                self.topLabel.isHidden = true
                self.currentCourseLabel.isHidden = true
                self.classNameCapsule.isHidden = true
                self.timeRemaining.isHidden = true
                self.noCoursesLeft.isHidden = false
                self.navigationItem.title = CourseViewModel.shared.scheduleType(on: Date())?.name ?? ""
                
            }
            else {
                
                self.topLabel.isHidden = false
                self.currentCourseLabel.isHidden = false
                self.classNameCapsule.isHidden = false
                self.timeRemaining.isHidden = false
                self.noCoursesLeft.isHidden = true
                self.classLengthLabel.text = (CourseViewModel.shared.currentOrNextCourse()?.startTime.formattedHMTime() ?? "00:00") + "-" +  (CourseViewModel.shared.currentOrNextCourse()?.endTime.formattedHMTime() ?? "00:00")
                self.timeRemaining.text = CourseViewModel.shared.formatTimeInterval(CourseViewModel.shared.currentCourseRemainingTime)
                if let course = CourseViewModel.shared.currentOrNextCourse() {
                    self.topLabel.text = course.isOngoing ? "Time remaining" : "Time till \(course.course.name) starts"
                }
                self.currentCourseLabel.text = CourseViewModel.shared.currentCourse()?.course.name ?? ""
                self.navigationItem.title = CourseViewModel.shared.scheduleType(on: Date())?.name ?? ""
            }
            
        }
        
    }
    
    
    func updateProgressRing() {
            guard let event = CourseViewModel.shared.currentOrNextCourse() else {
                progressRing.setProgress(to: 0, withAnimation: true)
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
            progressRing.setProgress(to: CGFloat(progress), withAnimation: true)
        }
}




extension ViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
            if let identifier = sheetPresentationController.selectedDetentIdentifier {
                if identifier == UISheetPresentationController.Detent.Identifier("highDetent") {
                    if let bottomSheetVC = sheetPresentationController.presentedViewController as? BottomSheetViewController {
                                    bottomSheetVC.updateUIForHighDetent()
                        bottomSheetVC.isFullyShown = true
                                }
                }
                else {
                    if let bottomSheetVC = sheetPresentationController.presentedViewController as? BottomSheetViewController {
                                    bottomSheetVC.updateUIForLowDetent()
                        bottomSheetVC.isFullyShown = false
                                }
                }
            }
        }
}

extension ViewController: BottomSheetDelegate {
    func openCourseInfoPage() {
        
    }
    
    
}

class TabSheetPresentationController : UISheetPresentationController {
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        // Update the container frame if there is a tab bar
        if let tc = presentingViewController as? UITabBarController, let cv = containerView {
            cv.clipsToBounds = true // ensure tab bar isn't covered
            var frame = cv.frame
            frame.size.height -= tc.tabBar.frame.height
            cv.frame = frame
        }
    }
}

class ProgressRingView: UIView {
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()

    var lineWidth = 22 {
        didSet {
            setupView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        createTrackLayer()
        createProgressLayer()
    }

    private func createTrackLayer() {
        trackLayer.strokeColor = UIColor.secondarySystemBackground.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = CGFloat(lineWidth)
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
    }

    private func createProgressLayer() {
        progressLayer.strokeColor = UIColor.systemPink.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = CGFloat(lineWidth)
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)
    }

    func setProgress(to progressConstant: CGFloat, withAnimation: Bool) {
        let clampedProgress = min(max(progressConstant, 0), 1)
        
//        if withAnimation && clampedProgress > progressLayer.strokeEnd {
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
//            
//            let animation = CABasicAnimation(keyPath: "strokeEnd")
//            animation.duration = 0.1
//            animation.fromValue = progressLayer.strokeEnd
//            animation.toValue = clampedProgress
//            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            animation.fillMode = .forwards
//            animation.isRemovedOnCompletion = false
//            
//            progressLayer.add(animation, forKey: "animateProgress")
//            
//            CATransaction.commit()
//        }
        
        progressLayer.strokeEnd = clampedProgress
    }



    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: .pi * 3 / 2, clockwise: true)
        
        trackLayer.path = circlePath.cgPath
        progressLayer.path = circlePath.cgPath
    }
}
