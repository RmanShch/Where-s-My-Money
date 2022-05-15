//
//  CategoriesViewController.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 1.05.22.
//

import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func categoriesVCDidTapNewCategory(vc: CategoriesViewController)
    func categoryVC(vc: CategoriesViewController, didTapEdit category: CategoryObject)
    
}

class CategoriesViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var upperView: UIView!
    
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var paymentTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var createCategoryButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    
    var tableView: UITableView?
    var moneyAccount: MoneyAccountObject
    var dataSource: CategoriesTableViewDataSource
    var persistenceManager: PersistenceManager?
    var paymentType: PaymentType?
    
    weak var delegate: CategoriesViewControllerDelegate?
    
    init(moneyAccount: MoneyAccountObject) {
        self.moneyAccount = moneyAccount
        dataSource = CategoriesTableViewDataSource(moneyAccount: moneyAccount)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        dataSource.delegate = self

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }
    
    private func setupTableView() {
        let tableview = UITableView(frame: containerView.frame)
        self.tableView = tableview
        containerView.addSubview(tableview)
        tableview.fillSuperview()
        self.tableView?.delegate = self
        self.tableView?.dataSource = dataSource
        dataSource.moneyAccount = moneyAccount
    }
    
    @IBAction func backButtonDidTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createCategoryButtonDidTap(_ sender: UIButton) {
        delegate?.categoriesVCDidTapNewCategory(vc: self)
        
    }
    
    @IBAction func categoryTypeSelection(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            dataSource.paymentType = nil
        } else if sender.selectedSegmentIndex == 1 {
            dataSource.paymentType = .expense
        } else if sender.selectedSegmentIndex == 2 {
            dataSource.paymentType = .income
        }
        
        tableView?.reloadData()
    }
    
}



extension CategoriesViewController : CategoryEditorViewControllerDelegate {
    func categoryEditor(vc: CategoryEditorViewController, didCreateNew category: CategoryObject) {
        persistenceManager?.saveNewCategory(category, in: moneyAccount)
        tableView?.reloadData()
    }
    
    func categoryEditor(vc: CategoryEditorViewController, didEdit category: CategoryObject, with new: CategoryObject) {
        persistenceManager?.saveEditedCategory(old: category, new: new, in: moneyAccount)
        tableView?.reloadData()
    }
}

extension CategoriesViewController: CategoriesTableViewDataSourceDelegate {
    func categoryTableViewDidTapDelete(category: CategoryObject) {
        let alertController = UIAlertController(title: "Are you sure?", message: "All operations in this category will not have any category then.", preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "DELETE", style: .destructive, handler: {_ in
            self.persistenceManager?.deleteCategory(category, from: self.moneyAccount)
            self.tableView?.reloadData()
        })
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            return
        })
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        present(alertController, animated: true, completion: nil)

    }
    
    func categoryTableViewDidTapEdit(category: CategoryObject) {
        delegate?.categoryVC(vc: self, didTapEdit: category)
    }
    
    
}
