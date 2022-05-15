//
//  Currency.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 12.04.22.
//

import Foundation
import RealmSwift

enum PaymentType: String, PersistableEnum {
    case expense = "expense"
    case income = "income"
}
