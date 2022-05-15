//
//  CategoriesTableViewDataSource.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 1.05.22.
//

import Foundation
import UIKit

protocol CategoriesTableViewDataSourceDelegate: AnyObject {
    func categoryTableViewDidTapEdit(category: CategoryObject)
    func categoryTableViewDidTapDelete(category: CategoryObject)
}


class CategoriesTableViewDataSource: NSObject, UITableViewDataSource {
    
    var moneyAccount: MoneyAccountObject
    var sortedCategories = [String : [CategoryObject]]()
    var sortedKeysArray = [String]()
    var paymentType: PaymentType?
    
    weak var delegate: CategoriesTableViewDataSourceDelegate?
    
    init(moneyAccount: MoneyAccountObject) {
        self.moneyAccount = moneyAccount
    }
    
    
    private func showCategories() {
        let empty: [String : [CategoryObject]] = [:]
        let sortedCategories = moneyAccount.allCategories.reduce(into: empty) { result, object in
            let categoryTypeName = object.type.rawValue
            let existing = result[categoryTypeName ] ?? []
            result[categoryTypeName ] = existing + [object]
        }
        self.sortedCategories = sortedCategories
        sortedKeysArray = sortedCategories.keys.sorted(by: { $0 < $1 })
    }
    
    @objc func didTapDeleteCategoryButton(sender: UIButton) {
        let category = moneyAccount.allCategories[sender.tag]
      
        delegate?.categoryTableViewDidTapDelete(category: category)
    }
    
    @objc func didTapEditCategoryButton(sender: UIButton) {
        let category = moneyAccount.allCategories[sender.tag]
        
        delegate?.categoryTableViewDidTapEdit(category: category)
    }
    
    // like filter by segmented control to whow all/expense/income categories

    func numberOfSections(in tableView: UITableView) -> Int {
        showCategories()
        if paymentType == nil {
            return sortedKeysArray.count
        } else if paymentType == .expense {
            return 1
        } else {
            sortedKeysArray = sortedCategories.keys.sorted(by: { $0 > $1 })
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedKeysArray[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedCategories[sortedKeysArray[section]]?.count ?? 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let thisSection = sortedKeysArray[indexPath.section]
        
        guard let category = sortedCategories[thisSection]?[indexPath.row] else {
            return UITableViewCell()
        }
        
        let id = "categoryCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: id) as? CategoryTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("CategoryTableViewCell", owner: nil, options: nil)?[0] as? CategoryTableViewCell
        }
        
        cell?.iconImageView.image = UIImage(systemName: category.iconName)
        
        cell?.nameLabel.text = category.name
        
        let index = moneyAccount.allCategories.firstIndex {
            $0.name == category.name && $0.type == category.type
        }
        if index != nil {
            
            cell?.editButton.tag = index!
            cell?.editButton.addTarget(self, action: #selector(didTapEditCategoryButton), for: .touchUpInside)
            
            cell?.deleteButton.tag = index!
            cell?.deleteButton.addTarget(self, action: #selector(didTapDeleteCategoryButton), for: .touchUpInside)
        }
        
        
        return cell ?? UITableViewCell()
        
    }
    

    


}
