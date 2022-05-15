//
//  NewMoneyAccountViewController.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 12.04.22.
//

import UIKit

// RENAME VC AND DELEGATE TO EDITACCOUNT MAYBE
protocol AccountEditorViewControllerDelegate: AnyObject {
//    func newMoneyAccountViewController(_ controller: UIViewController, didCreateNew moneyAccount: MoneyAccount)
    func accountEditorVC(_ controller: UIViewController, didCreateNew moneyAccount: MoneyAccountObject)
    
    func accountEditorVCdidEditAccount(vc: UIViewController, old: MoneyAccountObject, new: MoneyAccountObject)
}

class AccountEditorViewController: UIViewController {
    
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var initialMoneyTextField: UITextField!
    @IBOutlet weak var currencyPopUpButton: UIButton!
    @IBOutlet weak var currencyIconImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    
    weak var delegate: AccountEditorViewControllerDelegate?
    
    var currentAccount: MoneyAccountObject?

    let currenciesDict = ["$" : "dollarsign.circle",
                          "€" : "eurosign.circle",
                          "₴" : "hryvniasign.circle",
                          "Br" : "mustache",
                          "₽" : "rublesign.circle"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performInitialConfiguration()
        
    }
    
    private func performInitialConfiguration() {
        hideKeyboardWhenTappedAround()
        checkCurrentAccount()
        initialMoneyTextField.keyboardType = .decimalPad
        setUpPupUpCurrencyButton()
        
        
    }

    // creates popUpButton menu with currencies
    func setUpPupUpCurrencyButton() {
        var actions: [UIAction] = []
        
        for currency in currenciesDict.keys {
            
            actions.append(UIAction(title: currency) { _ in
                self.currencyPopUpButton.setTitle(currency, for: .normal)
                self.currencyPopUpButton.setImage(nil, for: .normal)
                self.currencyIconImageView.image = UIImage(systemName: self.currenciesDict[currency] ?? "questionmark")
            })
        }
        
        currencyPopUpButton.menu = UIMenu(children: actions)
        currencyPopUpButton.showsMenuAsPrimaryAction = true
        
    }

    // checks if I tapped account and came here to edit or if a tapped create new account
    private func checkCurrentAccount() {
        guard let currentAccount = currentAccount else {
            setUpPupUpCurrencyButton()
            return
        }
        
        accountNameTextField.text = currentAccount.name
        initialMoneyTextField.text = String(currentAccount.initialBalance)
        currencyPopUpButton.setTitle(currentAccount.currency, for: .normal)
        
    }
    
    
    @IBAction func doneButtonDidTap(_ sender: Any) {
        
        let name = accountNameTextField.text ?? "moneyAcc"
        let initialMoney = Double(initialMoneyTextField.text ?? "") ?? 0
        guard currencyPopUpButton.titleLabel?.text != "select" else { return }
        let currency = currencyPopUpButton.titleLabel?.text

        let accIconName = currenciesDict[currency ?? "$"]
        let moneyAccount = MoneyAccountObject(name: name,
                                              currency: currency!,
                                              amountOfMoney: initialMoney,
                                              iconName: accIconName!)
        
        //checks if it was editing account or creating new. and if it was editing, it checks if anything in this account changed. and decides, save it as new account or as old but edited.
        if currentAccount == nil {
            delegate?.accountEditorVC(self, didCreateNew: moneyAccount)
        } else if currentAccount != nil && currentAccount == moneyAccount {
            return
        } else if currentAccount != nil && currentAccount != moneyAccount {
            delegate?.accountEditorVCdidEditAccount(vc:self, old: currentAccount!, new: moneyAccount)
        }

        // I think i don't need to tell coordinator about it :)
        navigationController?.popViewController(animated: true)
    }
    
}
