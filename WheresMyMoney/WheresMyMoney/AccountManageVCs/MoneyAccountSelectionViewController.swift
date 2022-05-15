//
//  MoneyAccountSelectionViewController.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 12.04.22.
//

import UIKit

fileprivate struct ViewConfig {
    static let kCellHeight: CGFloat = 80
    static let kNumberOfRows: Int = 3
}

protocol MoneyAccountSelectionViewControllerDelegate: AnyObject {
    
    func moneyAccountSelectionViewController(_ controller: UIViewController, didSelect moneyAccount: MoneyAccountObject, savedWith persistenceManager: PersistenceManager)

    func moneyAccountSelectionViewControllerDidTapNewAccount(_ controller: MoneyAccountSelectionViewController)
    
    func moneyAccountSelectionViewControllerDidTapEditAccount(vc: MoneyAccountSelectionViewController, account: MoneyAccountObject)
}

class MoneyAccountSelectionViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var accountListTableView: ContentSizedTableView!
    @IBOutlet weak var chooseMoneyAccLabel: UILabel!
    
    weak var delegate: MoneyAccountSelectionViewControllerDelegate?
    var moneyAccounts: [MoneyAccountObject]? = []
    var selectedMoneyAccount: MoneyAccountObject?
    let image = UIImage(systemName: "creditcard.circle")
    
    var persistenceManager: PersistenceManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performInitialCofiguration()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadStoredObjects()
    }
    
    
    func loadStoredObjects() {
        let accounts = persistenceManager?.loadAllAccounts()
        moneyAccounts = accounts
        accountListTableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: accountListTableView.frame.width, height: accountListTableView.contentSize.height)
    }
    
    private func performInitialCofiguration() {
        chooseMoneyAccLabel.text = "Choose money account \n you want to use:"
        
        persistenceManager = RealmManager()
        
        accountListTableView.delegate = self
        accountListTableView.dataSource = self
        accountListTableView.isScrollEnabled = false
        
    }
    
    // objc delete methods because i gave these buttons targets and tag to manipulate an object I need through index in array which is  same as indexPath.row, so, this tag
    @objc func didTapDeleteAccountButton(sender: UIButton) {
        
        guard let item = moneyAccounts?[sender.tag] else { return }
        let alertController = UIAlertController(title: "This account will be deleted.", message: "Are you sure?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "DELETE", style: .destructive, handler: {_ in
            self.persistenceManager?.delete(account: item)
            self.loadStoredObjects() })
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            return
        })
        alertController.addAction(action1)
        alertController.addAction(action2)
        present(alertController, animated: true, completion: nil)
        
        accountListTableView.reloadData()
    }
    
    @objc func didTapEditButton(sender: UIButton) {
        guard let item = moneyAccounts?[sender.tag] else { return }
        delegate?.moneyAccountSelectionViewControllerDidTapEditAccount(vc: self, account: item)
    }

}

extension MoneyAccountSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ViewConfig.kCellHeight
    }
    
    // if there is an account - opens accEditorVC with all this acc info, if no - opens same VC to create new account
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= moneyAccounts!.count {
            delegate?.moneyAccountSelectionViewControllerDidTapNewAccount(self)
        } else {
            selectedMoneyAccount = moneyAccounts?[indexPath.row]
            delegate?.moneyAccountSelectionViewController(self, didSelect: selectedMoneyAccount!, savedWith: persistenceManager!)
        }
    }
    
    
}

extension MoneyAccountSelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewConfig.kNumberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let moneyAccounts = moneyAccounts else {
            return AccountTableViewCell() }
        
        let id = "accountCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: id) as? AccountTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("AccountTableViewCell", owner: nil, options: nil)?[0] as? AccountTableViewCell
        }
        
        if indexPath.row >= moneyAccounts.count {
            cell?.deleteButton.isHidden = true
            cell?.editButton.isHidden = true
            return cell!
        } else {
            let moneyAccount = moneyAccounts[indexPath.row]
            
            cell?.iconImageView.image = UIImage(systemName: moneyAccount.iconName ?? "dollarsign.circle")
            cell?.nameLabel.text = moneyAccount.name
            cell?.amountOfMoneyLabel.text = String(moneyAccount.currentBalance) + moneyAccount.currency
            
            // tis tag is the same as account's index in accs array
            cell?.deleteButton.tag = indexPath.row
            cell?.deleteButton.addTarget(self, action: #selector(didTapDeleteAccountButton), for: .touchUpInside)
            cell?.editButton.tag = indexPath.row
            cell?.editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
            
            return cell!
        }
    }
    
}

extension MoneyAccountSelectionViewController: AccountEditorViewControllerDelegate {
    
    // changes previous account data with current (after editing)
    func accountEditorVCdidEditAccount(vc: UIViewController, old: MoneyAccountObject, new: MoneyAccountObject) {
        persistenceManager?.saveEditedAccount(old: old, new: new)
        accountListTableView.reloadData()
    }
    
    // saves new account
    func accountEditorVC(_ controller: UIViewController, didCreateNew moneyAccount: MoneyAccountObject) {
        persistenceManager?.save(account: moneyAccount)
        loadStoredObjects()
    }
}
