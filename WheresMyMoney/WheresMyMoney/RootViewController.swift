//
//  RootViewController.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 13.04.22.
//

import Foundation
import UIKit

class RootViewController: UIViewController {
    private var moneyAccountsCoordinator: MoneyAccountsCoordinator?
    private var moneyOperationsCoordinator: MoneyOperationsCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        activateMoneyAccountsCoordinator()
    }
    
    func activateMoneyAccountsCoordinator() {
        moneyAccountsCoordinator = MoneyAccountsCoordinator(rootParentController: self, delegate: self)
        moneyAccountsCoordinator?.activate()
        
    }
    
    func activateMoneyOperationsCoordinator(with moneyAccount: MoneyAccountObject, and persistenceMaanager: PersistenceManager) {
        moneyOperationsCoordinator = MoneyOperationsCoordinator(moneyAccount: moneyAccount, rootParentController: self, persistenceManager: persistenceMaanager, delegate: self)
        moneyOperationsCoordinator?.activate()
    }
}

extension RootViewController: MoneyAccountsCoordinatorDelegate {

    func moneyAccsCoordinator(_ coordinator: MoneyAccountsCoordinator, didSelect moneyAccount: MoneyAccountObject, savedWith persistenceManager: PersistenceManager) {
        coordinator.deactivate()
        activateMoneyOperationsCoordinator(with: moneyAccount, and: persistenceManager)
    }
    
}

extension RootViewController: MoneyOperationsCoordinatorDelegate {
    func moneyOppsCoordinator(_ coordinator: MoneyOperationsCoordinator, edits moneyAccount: MoneyAccountObject, savedWith persistenceManager: PersistenceManager) {
        
    }
    
    func moneyOppsCoordinatordidTapChangeAccount(_ coordinator: MoneyOperationsCoordinator) {
        coordinator.deactivate()
        activateMoneyAccountsCoordinator()
    }
    
    
}
