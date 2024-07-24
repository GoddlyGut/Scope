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
    var classNameCapsule = UIView()
    var classNameLabel = UILabel()
    
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
}

extension ViewController {
    func style() {
        self.title = "Home"
        view.backgroundColor = .systemBackground
        
        centerStackView.translatesAutoresizingMaskIntoConstraints = false
        centerStackView.axis = .vertical
        centerStackView.alignment = .center
        centerStackView.spacing = 4
        
        topLabel.text = "..."
        topLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        centerStackView.addArrangedSubview(topLabel)
        
        
        
        timeRemaining.font = UIFont.systemFont(ofSize: 35, weight: .black)
        timeRemaining.isHidden = true
        timeRemaining.textAlignment = .center
        centerStackView.addArrangedSubview(timeRemaining)
        
        
        noCoursesLeft.font = UIFont.systemFont(ofSize: 30, weight: .black)
        noCoursesLeft.numberOfLines = 0
        noCoursesLeft.textAlignment = .center
        noCoursesLeft.text = "No courses\nleft today"
        noCoursesLeft.isHidden = true
        centerStackView.addArrangedSubview(noCoursesLeft)
        
        currentCourseLabel.text = CourseViewModel.shared.currentCourse()?.name
        currentCourseLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        
        //centerStackView.addArrangedSubview(currentCourseLabel)
        
        
        view.addSubview(centerStackView)
        
        progressRing.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(progressRing)
        
        classNameCapsule.translatesAutoresizingMaskIntoConstraints = false
        classNameCapsule.layer.cornerRadius = 50/2
        classNameCapsule.backgroundColor = .secondarySystemBackground
        classNameCapsule.isHidden = true
        
        classNameLabel.translatesAutoresizingMaskIntoConstraints = false
        classNameLabel.text = "Math"
        classNameLabel.font = .systemFont(ofSize: 21, weight: .bold)
        classNameLabel.numberOfLines = 0
        classNameCapsule.addSubview(classNameLabel)
        progressRing.addSubview(classNameCapsule)
        
    }
    
    func layout() {
        NSLayoutConstraint.activate([
            centerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            progressRing.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
                        progressRing.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        progressRing.widthAnchor.constraint(equalToConstant: 300),
                        progressRing.heightAnchor.constraint(equalTo: progressRing.widthAnchor),
            centerStackView.centerYAnchor.constraint(equalTo: progressRing.centerYAnchor),
            
            classNameCapsule.centerXAnchor.constraint(equalTo: progressRing.centerXAnchor),
            classNameCapsule.leadingAnchor.constraint(equalTo: classNameLabel.leadingAnchor, constant: -20),
            classNameCapsule.trailingAnchor.constraint(equalTo: classNameLabel.trailingAnchor, constant: 20),
            classNameCapsule.heightAnchor.constraint(equalToConstant: 40),
            classNameCapsule.bottomAnchor.constraint(equalTo: progressRing.bottomAnchor, constant: -50),
            
            classNameLabel.centerXAnchor.constraint(equalTo: classNameCapsule.centerXAnchor),
            classNameLabel.centerYAnchor.constraint(equalTo: classNameCapsule.centerYAnchor),
        ])
    }
    
    @objc private func presentSheet() {
        let sheetViewController = BottomSheetViewController()
            //sheetViewController.modalPresentationStyle = .pageSheet
            
            
            if let sheet = sheetViewController.sheetPresentationController {
                
                let customHighDetent = UISheetPresentationController.Detent.custom(identifier: UISheetPresentationController.Detent.Identifier("highDetent")) { context in
                    return context.maximumDetentValue - 0.5
                }
                
                let customLowDetent = UISheetPresentationController.Detent.custom(identifier: UISheetPresentationController.Detent.Identifier("lowDetent")) { context in
                    return context.maximumDetentValue * 0.45
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
            
            
            
            
            
            
            if CourseViewModel.shared.findCurrentOrNextCourseEvent() == nil {
                self.topLabel.isHidden = true
                self.currentCourseLabel.isHidden = true
                self.classNameCapsule.isHidden = true
                self.timeRemaining.isHidden = true
                self.noCoursesLeft.isHidden = false
                
            }
            else {
                self.topLabel.isHidden = false
                self.currentCourseLabel.isHidden = false
                self.classNameCapsule.isHidden = false
                self.timeRemaining.isHidden = false
                self.noCoursesLeft.isHidden = true
                self.timeRemaining.text = CourseViewModel.shared.formatTimeInterval(CourseViewModel.shared.currentCourseRemainingTime)
                if let course = CourseViewModel.shared.findCurrentOrNextCourseEvent() {
                    self.topLabel.text = course.isOngoing ? "Time remaining" : "Time till \(course.course.name) starts"
                }
                self.currentCourseLabel.text = CourseViewModel.shared.currentCourse()?.name ?? ""
            }
            
        }
        
    }
    
    
    func updateProgressRing() {
            guard let event = CourseViewModel.shared.findCurrentOrNextCourseEvent() else {
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



class ProgressRingView: UIView {
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()

    var lineWidth = 20 {
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
