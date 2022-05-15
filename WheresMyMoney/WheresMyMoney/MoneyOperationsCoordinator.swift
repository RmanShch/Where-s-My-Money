//
//  MoneyOperationsCoordinator.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 13.04.22.
//

import Foundation
import UIKit

// Coordinator for main ViewController with information about all operations and categories and which is responsible for creating and editing operations and categories

protocol MoneyOperationsCoordinatorDelegate {
    func moneyOppsCoordinator(_ coordinator: MoneyOperationsCoordinator, edits moneyAccount: MoneyAccountObject, savedWith persistenceManager: PersistenceManager)
    func moneyOppsCoordinatordidTapChangeAccount(_ coordinator: MoneyOperationsCoordinator)
}

class MoneyOperationsCoordinator {
    
    private var moneyAccount: MoneyAccountObject
    private var navigationController: UINavigationController?
    private var rootParentController: UIViewController
    private var persistenceManager: PersistenceManager
    
    var delegate: MoneyOperationsCoordinatorDelegate?

    init(moneyAccount: MoneyAccountObject, rootParentController: UIViewController, persistenceManager: PersistenceManager, delegate: MoneyOperationsCoordinatorDelegate) {
        self.moneyAccount = moneyAccount
        self.rootParentController = rootParentController
        self.persistenceManager = persistenceManager
        self.delegate = delegate
    }
    
    // Initializes main VC with all operations
    func activate() {
        let moneyOperationsViewController = MainOperationsViewController(moneyAccount: moneyAccount, delegate: self, persistenceManager: persistenceManager)
        navigationController = UINavigationController(rootViewController: moneyOperationsViewController)
        navigationController?.navigationBar.isHidden = true
        moneyOperationsViewController.coordinator = DataSourceCoordinator(moneyAccount: moneyAccount)
        rootParentController.add(navigationController!)
    }
    
    func deactivate() {
        navigationController?.remove()
        navigationController = nil
    }
}


extension MoneyOperationsCoordinator: MainOperationsViewControllerDelegate {
    
    // returns us to the first screen with all accounts list
    func mainOperationsVCdidTapChangeAccount(vc: MainOperationsViewController) {
        delegate?.moneyOppsCoordinatordidTapChangeAccount(self)
    }
    
    // opens operation editor vc to edit operation or just look its details
    func mainOperationsVC(vc: MainOperationsViewController, didTap operation: OperationObject) {
        let addOperationVC = OperationEditorViewController(moneyAccount: moneyAccount)
        addOperationVC.delegate = vc
        addOperationVC.currentOperation = operation
        navigationController?.pushViewController(addOperationVC, animated: true)
    }
    
    // opens operation editor vc to create new operation or just look its details
    func mainOperationsVCDidTapAddButton(vc: MainOperationsViewController) {
        let addOperationVC = OperationEditorViewController(moneyAccount: moneyAccount)
        addOperationVC.delegate = vc
        navigationController?.pushViewController(addOperationVC, animated: true)
    }
    
    // opens categories VC with list of all availible categories
    func mainOperationsVCdidTapCategoriesButton(vc: MainOperationsViewController) {
        let categoriesVC = CategoriesViewController(moneyAccount: moneyAccount)
        categoriesVC.delegate = vc
        categoriesVC.persistenceManager = persistenceManager
        navigationController?.pushViewController(categoriesVC, animated: true)
    }
    
    // opens category editor vc to create new category
    func mainOperationsVCDidTapNewCategory(vc: CategoriesViewController) {
        let newCategoryVC = CategoryEditorViewController()
        newCategoryVC.delegate = vc
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }
    
    // opens category editor to edit category
    func mainOperationsVC(vc: CategoriesViewController, didTapEdit category: CategoryObject) {
        let categoryEditorVC = CategoryEditorViewController()
        categoryEditorVC.delegate = vc
        categoryEditorVC.currentCategory = category
        navigationController?.pushViewController(categoryEditorVC, animated: true)
    }

}
