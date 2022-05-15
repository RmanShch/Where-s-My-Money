//
//  OperationObj.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 24.04.22.
//

import Foundation
import RealmSwift

class OperationObject: Object {

    @Persisted var date: Date = Date()
    @Persisted var amountOfMoney: Double
    @Persisted var additionalInformation: String?
    @Persisted var operationType: PaymentType
    @Persisted var category: CategoryObject?
    
    var dayOfOperation: Date {
        let dateFormatter = DateFormatter()
        return dateFormatter.calendar.startOfDay(for: date)
    }
    
    var monthOfOperation: Date {
        let components = Calendar.current.dateComponents([.month, .year], from: date)
        guard let month = Calendar.current.date(from: components) else { return Date()}
        return month
    }
    
    var operationTimeString: String {
        makeStringOf(date: date, with: "HH:mm")
    }
    
    var operationDateString: String {
        makeStringOf(date: date, with: "dd MMM yyyy, HH:mm")
    }
    
    var operationDayAndTimeString: String {
        makeStringOf(date: date, with: "dd MMM, HH:mm")
    }
    
    convenience init(date: Date, amountOfMoney: Double, additionalInformation: String?, operationType: PaymentType, category: CategoryObject) {
        self.init()
        self.amountOfMoney = amountOfMoney
        self.date = date
        self.additionalInformation = additionalInformation
        self.operationType = operationType
        self.category = category
    }
    
    private func makeStringOf(date: Date, with dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
}
