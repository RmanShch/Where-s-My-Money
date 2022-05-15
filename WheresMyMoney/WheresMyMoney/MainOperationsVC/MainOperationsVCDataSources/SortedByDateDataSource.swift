//
//  SortedByDateDataSource.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 26.04.22.
//

import Foundation
import UIKit

protocol SortedByDateDataSourceDelegate: AnyObject {
    func setSortedOperations(dict: [Date : [OperationObject]], and keys: [Date], expenses sum: Double)
    func operationIsDeleted(operation: OperationObject)
    func showAlertController(ac: UIAlertController)
}

protocol MainTableViewDataSource: AnyObject {
    func timePeriodChanged(to new: DateComponents)
    func sectionHeaderTapped(section: Int)
}

class SortedByDateDataSource: NSObject, UITableViewDataSource {
    var moneyAccount: MoneyAccountObject
    
    var sortedByDateOperations = [Date : [OperationObject]]()
    var sortedByDateKeysArray = [Date]()
    var timePeriod: DateComponents?
    var totalSpent: Double?
    
    
    // this array is for section headers. allows to see if section should be shown (true) or not ( false)
    var sectionShownBoolArray: [Bool] = []
    var footerString: String = ""
    
    weak var delegate: SortedByDateDataSourceDelegate?
    
    init(moneyAccount: MoneyAccountObject) {
        self.moneyAccount = moneyAccount
    }
    
    
    // main sorting method
    private func setupTableViewData() {
        
        let halfSortedOperations = filterOperationsByTimePeriod()
        
        if timePeriod == Calendar.current.dateComponents([.year], from: Date()) {
            sortedByDateOperations = Dictionary(grouping: moneyAccount.allOperations.sorted(by: { $0.date > $1.date })) { (element) -> Date in
                return element.monthOfOperation
            }
        } else {
            sortedByDateOperations = Dictionary(grouping: halfSortedOperations.sorted(by: { $0.date > $1.date })) { (element) -> Date in
                return element.dayOfOperation
            }
        }
        
        sortedByDateKeysArray = sortedByDateOperations.keys.sorted(by: { $0 > $1 })
        totalSpent = calculateSum(in: halfSortedOperations, by: .expense)
        
        delegate?.setSortedOperations(dict: sortedByDateOperations, and: sortedByDateKeysArray, expenses: totalSpent ?? 0.0)
        
        fillSectionBoolArray()
    }
    
    // filtering method used before sorting
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
    
    // calculates total expenses or incomes after filtering operations
    private func calculateSum(in operations: [OperationObject], by type: PaymentType) -> Double  {

        let operations = operations.filter { operation in
            operation.operationType == type
        }
        
        let sum = operations.reduce(into: 0.0) { ($0 += $1.amountOfMoney) }
        
        return sum
    }
    
    // this count == sections.count. so i give every section' index bool to observe its changes
    private func fillSectionBoolArray() {
        for _ in 0..<sortedByDateKeysArray.count {
            self.sectionShownBoolArray.append(true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        setupTableViewData()
        return sortedByDateKeysArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
       // tableView.reloadData()
        guard let sectionOperations = sortedByDateOperations[sortedByDateKeysArray[section]] else { return nil }

        let expensesSum = calculateSum(in: sectionOperations, by: .expense)
        let incomesSum = calculateSum(in: sectionOperations, by: .income)
        let currency = moneyAccount.currency
        footerString = "Total spent: \(expensesSum)\(currency). Total earned: \(incomesSum)\(currency)"
        
        return footerString
    }
    
    // here depending on that bool array you've seen before it decides , whould it show these operations (rows) or not
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sectionShownBoolArray[section] {
            return sortedByDateOperations[sortedByDateKeysArray[section]]?.count ?? 0
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let thisSection = sortedByDateOperations[sortedByDateKeysArray[indexPath.section]]
        
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
        
        if timePeriod != Calendar.current.dateComponents([.year], from: Date()) {
            cell?.timeLabel.text = operation.operationTimeString
        } else {
            cell?.timeLabel.text = operation.operationDayAndTimeString
        }
        
        cell?.categoryLabel.text = operation.category?.name
        cell?.iconImageView.image = UIImage(systemName: operation.category?.iconName ?? "questionmark")
        
        return cell ?? UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let operation = sortedByDateOperations[sortedByDateKeysArray[indexPath.section]]?[indexPath.row] else { return }
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
            tableView.reloadData()
        })
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            return
        })
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        delegate?.showAlertController(ac: alertController)
    }
    
}
extension SortedByDateDataSource: MainTableViewDataSource {
    //here i catch all changes from main VC
    
    func timePeriodChanged(to new: DateComponents) {
        timePeriod = new
    }
    
    func sectionHeaderTapped(section: Int) {
        sectionShownBoolArray[section].toggle()
    }
    
    
}
