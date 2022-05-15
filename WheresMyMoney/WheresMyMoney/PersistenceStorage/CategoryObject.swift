//
//  CategoryObj.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 24.04.22.
//

import Foundation
import RealmSwift

class CategoryObject: Object {
    
    @Persisted var name: String
    @Persisted var iconName: String
    @Persisted var totalSpent: Double
    @Persisted var type: PaymentType
    
    
    convenience init(name: String, iconName: String, type: PaymentType) {
        self.init()
        self.name = name
        self.iconName = iconName
        self.type = type
        
    }
    
}
