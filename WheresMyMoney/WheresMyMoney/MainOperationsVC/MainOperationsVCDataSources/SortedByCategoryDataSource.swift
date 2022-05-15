//
//  sortedByCategoryDataSource.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 25.04.22.
//

import Foundation
import UIKit

protocol SortedByCategoryDataSourceDelegate: AnyObject {
    func setSortedOperations(dict: [String : [OperationObject]], and keys: [String], expenses sum: Double)
    func operationIsDeleted(operation: OperationObject)
    func showAlertController(ac: UIAlertController)
    
}

// Here everything is almost like in the previous dataSource but with other sorting methods. Some of methods are completely same
class SortedByCategoryDataSource: NSObject, UITableViewDataSource, MainTableViewDataSource {
    
    var moneyAccount: MoneyAccountObject
    
    var sortedByCategoryOperations = [String : [OperationObject]]()
    var sortedByCategoryKeysArray = [String]()
    
    var timePeriod: DateComponents?
    var totalSpent: Double?
    
    var sectionShownBoolArray: [Bool] = []
    
    weak var delegate: SortedByCategoryDataSourceDelegate?
    
    
    init(moneyAccount: MoneyAccountObject) {
        self.moneyAccount = moneyAccount
    }
    
    
    private func sortOpsByCategoryName() {// -> [Date : [OperationObj]] {
        
        let halfSortedOperations = filterOperationsByTimePeriod()
        
        sortedByCategoryOperations = Dictionary(grouping: halfSortedOperations.sorted(by: { $0.date > $1.date })) { (element) -> String in
            return element.category?.name ?? "no category"
            
        }
        
        sortedByCategoryKeysArray = sortedByCategoryOperations.keys.sorted(by: { $0 > $1 })
        
        totalSpent = calculateSum(in: halfSortedOperations, by: .expense)
        
        delegate?.setSortedOperations(dict: sortedByCategoryOperations, and: sortedByCategoryKeysArray, expenses: totalSpent ?? 0.0)
        
        fillSectionBoolArray()

    }
    
    func filterOperationsByTimePeriod() -> [OperationObject] {
        let currentEra = Calendar.current.dateComponents([.era], from: Date())
        let filteredOperationsArray: [OperationObject] = []
        let filteredOperations = moneyAccount.allOperations.reduce(into: filteredOperationsArray) { result, operation in
            if Calendar.current.date(operation.date, matchesComponents: self.timePeriod ?? currentEra) {
                result.append(operation)
            }
        }
        
        return filteredOperations
    }
    
    private func calculateSum(in operations: [OperationObject], by type: PaymentType) -> Double  {

        let operations = operations.filter { operation in
            operation.operationType == type
        }
        
        let sum = operations.reduce(into: 0.0) { ($0 += $1.amountOfMoney) }
        
        return sum
    }
    
    private func fillSectionBoolArray() {
        for _ in 0..<sortedByCategoryKeysArray.count {
            self.sectionShownBoolArray.append(true)
        }
    }
    
    private func makeDateStringOf(date: Date, with dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sortOpsByCategoryName()
        return sortedByCategoryKeysArray.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sectionShownBoolArray[section] {
            return sortedByCategoryOperations[sortedByCategoryKeysArray[section]]?.count ?? 0
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sectionOperations = sortedByCategoryOperations[sortedByCategoryKeysArray[section]] else { return nil }
        let currency = moneyAccount.currency
        if sectionOperations.first?.operationType == .expense {
            let expensesSum = calculateSum(in: sectionOperations, by: .expense)
            let expensesString = "Total spent: \(expensesSum)\(currency)"
            return expensesString
        } else {
            let incomesSum = calculateSum(in: sectionOperations, by: .income)
            let incomesString = "Total earned: \(incomesSum)\(currency)"
            return incomesString
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let thisSection = sortedByCategoryOperations[sortedByCategoryKeysArray[indexPath.section]]

        guard let operation = thisSection?[indexPath.row] else {
            return UITableViewCell()
        }

        let id = "operationCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: id) as? OperationTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("OperationTableViewCell", owner: nil, options: nil)?[0] as? OperationTableViewCell
        }
        
        if operation.operationType == .expense {
            cell?.amountOfMoneyLabel.text = "-\(operation.amountOfMoney) \(moneyAccount.currency)"
        } else {
            cell?.amountOfMoneyLabel.text = "+\(operation.amountOfMoney) \(moneyAccount.currency)"
        }

        cell?.categoryLabel.text = makeDateStringOf(date: operation.date, with: "HH:mm")
        cell?.timeLabel.text = makeDateStringOf(date: operation.date, with: "dd MMM yyyy")
        cell?.iconImageView.image = UIImage(systemName: operation.category?.iconName ?? "questionmark")
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let operation = sortedByCategoryOperations[sortedByCategoryKeysArray[indexPath.section]]?[indexPath.row] else { return }
        let alertController = UIAlertController(title: "This operation will be deleted.", message: "Are you sure?", preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "DELETE", style: .destructive, handler: {_ in
            self.delegate?.operationIsDeleted(operation: operation)

            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
            if numberOfRows == 1 {
                tableView.deleteSections([indexPath.section], with: .fade)
            }
            tableView.endUpdates()
        })
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            return
        })
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        delegate?.showAlertController(ac: alertController)
    }
    
    
    func timePeriodChanged(to new: DateComponents) {
        timePeriod = new
    }
    
    func sectionHeaderTapped(section: Int) {
        sectionShownBoolArray[section].toggle()
    }
    
}

