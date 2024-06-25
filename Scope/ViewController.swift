//
//  ViewController.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import UIKit

class ViewController: UIViewController {

    
    
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
        
        
        
    }
    
    func layout() {
        NSLayoutConstraint.activate([
            
        ])
    }
    
    @objc private func presentSheet() {
        let sheetViewController = BottomSheetViewController()
            sheetViewController.modalPresentationStyle = .pageSheet
            
            
            if let sheet = sheetViewController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                
                sheet.prefersGrabberVisible = true
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
            
            present(sheetViewController, animated: true, completion: nil)
        }
}

