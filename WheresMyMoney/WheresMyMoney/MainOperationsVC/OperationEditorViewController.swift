//
//  AddNewOperationViewController.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 19.04.22.
//

import UIKit

protocol OperationEditorVCDelegate: AnyObject {
    
    func operationEditorVC(vc: UIViewController, didAdd newOpp: OperationObject, with category: CategoryObject)
    
    func operationEditorVCeditedOperation(vc: UIViewController, old: OperationObject, new: OperationObject)
}


class OperationEditorViewController: UIViewController {
    
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var oppTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var categoryIconImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var additionalInformationTextView: UITextView!
    
    
    weak var delegate: OperationEditorVCDelegate?
    
    var currentOperation: OperationObject?
    var oppType: PaymentType?
    
    var moneyAccount: MoneyAccountObject
    var category: CategoryObject?

    private var expenseActions: [UIAction] = []
    private var incomeActions: [UIAction] = []
    var categoryButtonTitle: String?

    
    init(moneyAccount: MoneyAccountObject) {
        self.moneyAccount = moneyAccount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        performInitialConfiguration()

    }
    
    private func performInitialConfiguration() {
        hideKeyboardWhenTappedAround()
        datePicker.locale = Locale(identifier: "en_GB")
        datePicker.maximumDate = Date()
        checkInitialOperation()
        doneButton.layer.cornerRadius = 10
        moneyTextField.keyboardType = .decimalPad
        
    }
    
    // check if it is creating of new operation or editing existing
    private func checkInitialOperation() {
        guard let currentOperation = currentOperation else {
            setCategoryButton(withInitial: "other")
            return }
        if currentOperation.operationType == .expense {
            oppTypeSegmentedControl.selectedSegmentIndex = 0
        } else {
            oppTypeSegmentedControl.selectedSegmentIndex = 1
        }
        
        category = currentOperation.category
        setupCategorySelectionConfig(with: category ?? CategoryObject())
        setCategoryButton(withInitial: category?.name ?? "other")
        datePicker.date = currentOperation.date
        moneyTextField.text = String(currentOperation.amountOfMoney)
        additionalInformationTextView.text = currentOperation.additionalInformation
        
    }
    
    // set value to category popup button. with iOS 15+ there are nice methods with which i wouldn't need to do it
    private func setupCategorySelectionConfig(with category: CategoryObject) {
        categoryButton.setTitle(category.name, for: .normal)
        
        categoryIconImageView.image = UIImage(systemName: category.iconName )
    }

    @IBAction func oppTypeSelection(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            oppType = .expense
            categoryButton?.menu = UIMenu(children: expenseActions)
            category = moneyAccount.allCategories.first(where: {
                $0.name == expenseActions.first?.title ?? "other"
            })
        } else {
            oppType = .income
            categoryButton?.menu = UIMenu(children: incomeActions)

            category = moneyAccount.allCategories.first(where: {
                $0.name == incomeActions.first?.title ?? "other"
            })
        }
        setupCategorySelectionConfig(with: category ?? CategoryObject())

    }

    
    @IBAction func doneButtonDidTap(_ sender: UIButton) {
        let money = Double(moneyTextField.text ?? "") ?? 0
        guard money != 0 else { return }
        
        let date = datePicker.date
        let oppType = oppType ?? .expense
        let category = self.category ?? CategoryObject(name: "other", iconName: "ellipsis.circle", type: oppType)
        let additionalInformation = additionalInformationTextView.text
        
        let moneyOpp = OperationObject(date: date,
                                    amountOfMoney: money,
                                    additionalInformation: additionalInformation,
                                    operationType: oppType,
                                    category: category)
        
        if currentOperation == nil {
            delegate?.operationEditorVC(vc: self, didAdd: moneyOpp, with: category)
        } else if currentOperation != nil && currentOperation == moneyOpp {
            return
        } else if currentOperation != nil && currentOperation != moneyOpp {
            delegate?.operationEditorVCeditedOperation(vc: self, old: currentOperation!, new: moneyOpp)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonDidTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setCategoryButton(withInitial value: String) {
 
        for category in self.moneyAccount.allCategories {
            if category.type == .expense {
                expenseActions.append(UIAction(title: category.name) { _ in
                    self.categoryIconImageView.image = UIImage(systemName: category.iconName)
                    self.category = category
                    self.categoryButton.setTitle(category.name, for: .normal)
                    self.categoryButton.setImage(nil, for: .normal)
                })
            } else {
                incomeActions.append(UIAction(title: category.name) { _ in
                    self.categoryIconImageView.image = UIImage(systemName: category.iconName)
                    self.category = category
                    self.categoryButton.setTitle(category.name, for: .normal)
                    self.categoryButton.setImage(nil, for: .normal)
                })
            }
        }
        categoryButton?.menu = UIMenu(children: expenseActions)
    }
    
}
