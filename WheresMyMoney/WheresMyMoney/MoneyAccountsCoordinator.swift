//
//  MoneyAccountsCoordinator.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 13.04.22.
//

import Foundation
import UIKit

// Coordinator for first ViewController with money accounts and controls for creating new and editing existing

protocol MoneyAccountsCoordinatorDelegate {
    func moneyAccsCoordinator(_ coordinator: MoneyAccountsCoordinator, didSelect moneyAccount: MoneyAccountObject, savedWith persistenceManager: PersistenceManager)
}

class MoneyAccountsCoordinator {
    private unowned var rootParentController: UIViewController
    private var navigationController: UINavigationController?
    
    var delegate: MoneyAccountsCoordinatorDelegate?
    
    init(rootParentController: UIViewController, delegate: MoneyAccountsCoordinatorDelegate?) {
        self.delegate = delegate
        self.rootParentController = rootParentController
    }
    
    // Shows first screen with account list
    func activate() {
        let moneyAccountsController = MoneyAccountSelectionViewController()
        navigationController = UINavigationController(rootViewController: moneyAccountsController)
        moneyAccountsController.delegate = self
        rootParentController.add(navigationController!)
    }
    
    // Removes itself before activation next coordinator
    func deactivate() {
        navigationController?.remove()
        navigationController = nil
    }
}

extension MoneyAccountsCoordinator: MoneyAccountSelectionViewControllerDelegate {
    
    // Opens account editor vc and gives it money account to edit
    func moneyAccountSelectionViewControllerDidTapEditAccount(vc: MoneyAccountSelectionViewController, account: MoneyAccountObject) {
        let viewController = AccountEditorViewController()
        navigationController?.navigationBar.tintColor = .white
        viewController.delegate = vc
        viewController.currentAccount = account
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // tells RootViewController, that he can deactivate because user selected account and now it is time to show VC with money operations on it
    func moneyAccountSelectionViewController(_ controller: UIViewController, didSelect moneyAccount: MoneyAccountObject, savedWith persistenceManager: PersistenceManager) {
        delegate?.moneyAccsCoordinator(self, didSelect: moneyAccount, savedWith: persistenceManager)
    }
    
    // Opens account editor vc to create new account. or not to create znd go back)
    func moneyAccountSelectionViewControllerDidTapNewAccount(_ controller: MoneyAccountSelectionViewController) {
        let vc = AccountEditorViewController()
        navigationController?.navigationBar.tintColor = .white
        vc.delegate = controller
        navigationController?.pushViewController(vc, animated: true)
    }
}
    
