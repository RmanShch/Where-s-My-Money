//
//  ContentSizedTableView.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 15.04.22.
//

import Foundation
import UIKit

// It just helped me make this tableView contentSized. Don't think I fully understand this property and property from exstensions for tableView
final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

//    override var intrinsicContentSize: CGSize {
//        layoutIfNeeded()
//        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
//    }
//    
}
