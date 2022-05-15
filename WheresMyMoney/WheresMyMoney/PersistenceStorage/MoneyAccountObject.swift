//
//  MoneyAccountObject.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 21.04.22.
//

import Foundation
import RealmSwift

class MoneyAccountObject: Object {
    @Persisted var name: String
    @Persisted var currency: String
    @Persisted var initialBalance: Double
    @Persisted var iconName: String? = "questionmark.circle"
    @Persisted var allOperations: List<OperationObject>
    @Persisted var allCategories: List<CategoryObject>
    @Persisted(primaryKey: true) var id = UUID().uuidString
    
    var spentTotal: Double {
        let expenseOperations = allOperations.filter { operation in
            operation.operationType == .expense
        }
        
        return expenseOperations.reduce(into: 0.0) {
            ($0 += $1.amountOfMoney)
        }
    }
    
    var earnedTotal: Double {
        let incomeOperations = allOperations.filter { operation in
            operation.operationType == .income
        }
        
        return incomeOperations.reduce(into: 0.0) {
            ($0 += $1.amountOfMoney)
        }
    }
    
    var currentBalance: Double {
        var money = initialBalance
        for operation in allOperations {
            if operation.operationType == .expense {
                money -= operation.amountOfMoney
            } else {
                money += operation.amountOfMoney
            }
        }
        return money
    }
    
        
    convenience init(name: String, currency: String, amountOfMoney: Double, iconName: String) {
        self.init()
        self.name = name
        self.currency = currency
        self.initialBalance = amountOfMoney
        self.iconName = iconName
        
        setInitialCategories()
    }
    
    
    private func setInitialCategories() {
        
        let categories = [CategoryObject(name: "other", iconName: "ellipsis", type: .expense),
                          CategoryObject(name: "pet", iconName: "pawprint", type: .expense),
                          CategoryObject(name: "education", iconName: "graduationcap", type: .expense),
                          CategoryObject(name: "health", iconName: "cross", type: .expense),
                          CategoryObject(name: "food", iconName: "cart", type: .expense),
                          CategoryObject(name: "fast food", iconName: "takeoutbag.and.cup.and.straw", type: .expense),
                          CategoryObject(name: "travel", iconName: "globe.europe.africa", type: .expense),
                          CategoryObject(name: "clothes", iconName: "tag", type: .expense),
                          CategoryObject(name: "house", iconName: "house", type: .expense),
                          CategoryObject(name: "main job", iconName: "1.square", type: .income),
                          CategoryObject(name: "secondary job", iconName: "2.square", type: .income),
                          CategoryObject(name: "gift", iconName: "gift", type: .income)]
        for category in categories {
            allCategories.append(category)
        }
    }
    
}


