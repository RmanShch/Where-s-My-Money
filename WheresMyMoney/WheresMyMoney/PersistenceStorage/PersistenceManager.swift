//
//  PersistenceManager.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 21.04.22.
//

import Foundation
import RealmSwift


protocol PersistenceManager {
    func save(account: MoneyAccountObject)
    func delete(account: MoneyAccountObject)
    func loadAllAccounts() -> [MoneyAccountObject]?
    func saveNewOperation(_ operation: OperationObject, in account: MoneyAccountObject)
    func saveEditedOperation(old: OperationObject, new: OperationObject, in account: MoneyAccountObject)
    func saveEditedCategory(old: CategoryObject, new: CategoryObject, in account: MoneyAccountObject)
    func deleteOperation(_ operation: OperationObject, from account: MoneyAccountObject)
    func saveEditedAccount(old: MoneyAccountObject, new: MoneyAccountObject)
    func saveNewCategory(_ category: CategoryObject, in account: MoneyAccountObject)
    func deleteCategory(_ category: CategoryObject, from account: MoneyAccountObject)
}


class RealmManager: PersistenceManager {
    
    private var realm: Realm!
    private var schemaVersion: UInt64 = 16
    
    init() {
        let config = Realm.Configuration(schemaVersion: schemaVersion) //{ migration, oldSchemaVersion in
//            migration.renameProperty(onType: TODOListItemObject.className(), from: "identifier", to: "id")
//        }
//        // Use this configuration when opening realms
        Realm.Configuration.defaultConfiguration = config

        realm = try! Realm()
    }
    
    func save(account: MoneyAccountObject) {
        let object = account
        try? realm.write {
            realm.add(object)
        }
    }
    
    func saveEditedAccount(old: MoneyAccountObject, new: MoneyAccountObject) {
        if let object = realm.object(ofType: MoneyAccountObject.self, forPrimaryKey: old.id) {
            try? realm.write {
                object.name = new.name
                object.currency = new.currency
                object.initialBalance = new.initialBalance
                object.iconName = new.iconName
            }
        }
    }
    
    func delete(account: MoneyAccountObject) {
        if let object = realm.object(ofType: MoneyAccountObject.self, forPrimaryKey: account.id) {
            try? realm.write {
                realm.delete(object)
            }
        }
    }
    
    func loadAllAccounts() -> [MoneyAccountObject]? {
        let objects = realm.objects(MoneyAccountObject.self)
        return objects.map { $0 }
    }
    
    
    func saveNewOperation(_ operation: OperationObject, in account: MoneyAccountObject) {
        let object = realm.object(ofType: MoneyAccountObject.self, forPrimaryKey: account.id)
        try? realm.write {
            object?.allOperations.append(operation)
        }
    }
    
    func saveEditedOperation(old: OperationObject, new: OperationObject, in account: MoneyAccountObject) {
        
        let object = realm.object(ofType: MoneyAccountObject.self, forPrimaryKey: account.id)
        guard let oldOperation = object?.allOperations.first(where: { operation in
            operation.date == old.date
        }) else { return }

            try? realm.write {
                oldOperation.date = new.date
                oldOperation.operationType = new.operationType
                oldOperation.category = new.category
                oldOperation.amountOfMoney = new.amountOfMoney
                oldOperation.additionalInformation = new.additionalInformation
            }
    }
    
    func deleteOperation(_ operation: OperationObject, from account: MoneyAccountObject) {
        let object = realm.object(ofType: MoneyAccountObject.self, forPrimaryKey: account.id)
        guard let operationToDelete = object?.allOperations.first(where: {
            $0.date == operation.date && $0.amountOfMoney == operation.amountOfMoney
        }) else { return }
        
        try? realm.write {
            realm.delete(operationToDelete)
        }
        
    }
    
    
    func saveNewCategory(_ category: CategoryObject, in account: MoneyAccountObject) {
        let object = realm.object(ofType: MoneyAccountObject.self, forPrimaryKey: account.id)
        try? realm.write {
            object?.allCategories.append(category)
        }
    }
    
    func saveEditedCategory(old: CategoryObject, new: CategoryObject, in account: MoneyAccountObject) {
        
        let object = realm.object(ofType: MoneyAccountObject.self, forPrimaryKey: account.id)
        
        guard let oldCategory = object?.allCategories.first(where: { category in
            category.name == old.name && category.type == old.type
        }) else { return }
        
            try? realm.write {
                oldCategory.name = new.name
                oldCategory.iconName = new.iconName
                oldCategory.type = new.type
            }
    }
    
    func deleteCategory(_ category: CategoryObject, from account: MoneyAccountObject) {
        let object = realm.object(ofType: MoneyAccountObject.self, forPrimaryKey: account.id)
        
        guard let categoryToDelete = object?.allCategories.first(where: {
            $0.name == category.name && $0.type == category.type
        }) else { return }
        
        try? realm.write {
            realm.delete(categoryToDelete)
        }
    }
    
}
