//
//  Extensions.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 13.04.22.
//

import Foundation
import UIKit

// Maxim, your extensions are great) Thank you :)
public extension UIViewController {
    ///If fillSuperview is set to false, child view layout should be configured manually.
    func add(_ child: UIViewController, fillSuperview: Bool = true) {
        add(child, in: view, fillSuperview: fillSuperview)
    }
    
    ///If fillSuperview is set to false, child view layout should be configured manually.
    func add(_ child: UIViewController, in containerView: UIView, fillSuperview: Bool = true) {
        // Just to be sure the container is withing the VC view hierarchy
        guard containerView.isDescendant(of: self.view) else { return }
        
        addChild(child)
        containerView.addSubview(child.view)
        if fillSuperview { child.view.fillSuperview() }
        child.didMove(toParent: self)
    }
    
    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

// ext to hide keyboard when tap outside of it
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        // keeps collectionview items touchable
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    func fillSuperview() {
        guard let superview = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = superview.translatesAutoresizingMaskIntoConstraints
        if translatesAutoresizingMaskIntoConstraints {
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            frame = superview.bounds
        } else {
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        }
    }
}

// this also helps my tableView be contentSized
extension UITableView {
    override open var intrinsicContentSize: CGSize {
        let height = self.contentSize.height
        let width = self.contentSize.width
        return CGSize(width: width, height: height)
    }
    
}
