//
//  MainTableViewCoordinator.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 26.04.22.
//

import Foundation
import UIKit


// Something like coordinator but for tableView's datasources. May be not very good and senseless decision
class DataSourceCoordinator: MainTableViewDataSourceCoordinator {
    
    var moneyAccount: MoneyAccountObject
    var tableViewDataSource: MainTableViewDataSource?
   // var delegate: DataSourceCoordinatorDelegate?
    
    init(moneyAccount: MoneyAccountObject) {
        self.moneyAccount = moneyAccount
    }
    
    
    // selects sortBydate datasource
    func sortObjectsByDate(in tableView: UITableView, in viewController: MainOperationsViewController, with timePeriod: DateComponents) {

        let dataSource = SortedByDateDataSource(moneyAccount: moneyAccount)
        tableViewDataSource = dataSource
        tableView.dataSource = tableViewDataSource as? UITableViewDataSource
        dataSource.delegate = viewController
        dataSource.timePeriod = timePeriod
    }
    
    // selects sort by category datasource
    func sortObjectsByCategory(in tableView: UITableView, in viewController: MainOperationsViewController, with timePeriod: DateComponents) {
        
        let dataSource = SortedByCategoryDataSource(moneyAccount: moneyAccount)
        tableViewDataSource = dataSource
        tableView.dataSource = tableViewDataSource as? UITableViewDataSource
        dataSource.delegate = viewController
        dataSource.timePeriod = timePeriod
    }
    
    // tells current datasource that timePeriod changed
    func timePeriodChanged(to timePeriod: DateComponents) {
        tableViewDataSource?.timePeriodChanged(to: timePeriod)
    }
    
    // tells current datasource that section header tapped
    func vcDidTapSectionHeader(in section: Int) {
        tableViewDataSource?.sectionHeaderTapped(section: section)
        
    }
    
    
    
    
    
    
    
}



