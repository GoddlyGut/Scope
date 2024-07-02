//
//  ViewController.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import UIKit

class ViewController: UIViewController {

    var centerStackView = UIStackView()
    var currentCourseLabel = UILabel()
    var currentCourseInfo = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()

        presentSheet()
        
        
    }
}

extension ViewController {
    func style() {
        self.title = "Home"
        view.backgroundColor = .systemBackground
        
        centerStackView.translatesAutoresizingMaskIntoConstraints = false
        centerStackView.axis = .vertical
        centerStackView.alignment = .center
        
        currentCourseLabel.text = CourseViewModel.shared.currentCourse()?.name
        //currentCourseInfo.text = CourseViewModel.shared.currentCourse()?.schedule.meetings[0].
        centerStackView.addArrangedSubview(currentCourseLabel)
        
        view.addSubview(centerStackView)
        
    }
    
    func layout() {
        NSLayoutConstraint.activate([
            centerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
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
}



extension ViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
            if let identifier = sheetPresentationController.selectedDetentIdentifier {
                if identifier == UISheetPresentationController.Detent.Identifier("highDetent") {
                    if let bottomSheetVC = sheetPresentationController.presentedViewController as? BottomSheetViewController {
                                    bottomSheetVC.updateUIForHighDetent()
                                }
                }
                else {
                    if let bottomSheetVC = sheetPresentationController.presentedViewController as? BottomSheetViewController {
                                    bottomSheetVC.updateUIForLowDetent()
                                }
                }
            }
        }
}
