//
//  TableViewContainerViewController.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 27.04.22.
//

import UIKit

fileprivate struct ViewConfig {
    static let kHeaderHeight: CGFloat = 25
    static let kFooterHeight: CGFloat = 22
    static let kHeaderViewOriginX: CGFloat = 5
    static let kHeaderViewWidth: CGFloat = 200
    static let kHeaderViewHeight: CGFloat = 25
    
}

protocol MainTableViewDataSourceCoordinator: AnyObject {
    func sortObjectsByDate(in tableView: UITableView, in viewController: MainOperationsViewController, with timePeriod: DateComponents)
    func sortObjectsByCategory(in tableView: UITableView, in viewController: MainOperationsViewController, with timePeriod: DateComponents)
    
    func timePeriodChanged(to timePeriod: DateComponents)
    
    func vcDidTapSectionHeader(in section: Int)
}

protocol MainOperationsViewControllerDelegate: AnyObject {
    func mainOperationsVCDidTapAddButton(vc: MainOperationsViewController)
    func mainOperationsVC(vc: MainOperationsViewController, didTap operation: OperationObject)
    func mainOperationsVCdidTapChangeAccount(vc: MainOperationsViewController)
    func mainOperationsVCdidTapCategoriesButton(vc: MainOperationsViewController)
    func mainOperationsVCDidTapNewCategory(vc: CategoriesViewController)
    func mainOperationsVC(vc: CategoriesViewController, didTapEdit category: CategoryObject)

    
}

class MainOperationsViewController: UIViewController {

    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var rightInfoView: UIView!
    @IBOutlet weak var leftInfoView: UIView!
    
    @IBOutlet weak var addOppButton: UIButton!
    
    @IBOutlet weak var timePeriodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var accountButton: UIButton!
    
    @IBOutlet weak var spentMoneyLabel: UILabel!
    @IBOutlet weak var timePeriodLabel: UILabel!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    
    @IBOutlet weak var categoriesButton: UIButton!
    
    @IBOutlet weak var sortMethodSelectionButton: UIButton!
    
    var tableView: UITableView?
    
    var delegate: MainOperationsViewControllerDelegate?
    var moneyAccount: MoneyAccountObject
    
    var persistenceManager: PersistenceManager
    
    // now i think that it was not the best idea and this vc could change data sources directly
    var coordinator: MainTableViewDataSourceCoordinator?
    
    var dataSource: UITableViewDataSource?
    
    var sortedByDateOperations: [Date : [OperationObject]]?
    var sortedByDateKeysArray: [Date]?
    var totalSpent: Double?
    
    var sortedByCategoryOperations: [String : [OperationObject]]?
    var sortedByCategoryKeysArray: [String]?
    
    // bool to change current sorting method ( current dataSource)
    var sortByDates = true
    
    var timePeriod: DateComponents?
    
    
    
    init(moneyAccount: MoneyAccountObject, delegate: MainOperationsViewControllerDelegate, persistenceManager: PersistenceManager) {
        self.delegate = delegate
        self.persistenceManager = persistenceManager
        self.moneyAccount = moneyAccount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performInitialVonfiguration()
              
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }
    
    private func performInitialVonfiguration() {
        let currentEra = Calendar.current.dateComponents([.era], from: Date())
        
        setupAccountButton()
        setupSortMethodSelectionButton()
        setupCategoryButton()
        setUpTableView()

        coordinator?.sortObjectsByDate(in: tableView ?? UITableView(), in: self, with: timePeriod ?? currentEra)
    }
    
    // gives account pullDown button menu
    private func setupAccountButton() {
        let image = UIImage(systemName: moneyAccount.iconName ?? "questionmark")
        accountButton.setImage(image, for: .normal)
        let actions = [UIAction(title: "Change account", handler: { _ in
            self.delegate?.mainOperationsVCdidTapChangeAccount(vc: self)
        })]
        accountButton.menu = UIMenu(children: actions)
    }
    
    // gives sorting method button menu and adds actions, which change tableView's dataSource
    private func setupSortMethodSelectionButton() {
        let currentEra = Calendar.current.dateComponents([.era], from: Date())
        let actions = [UIAction(title: "By date", handler: { _ in
            self.sortByDates = true
            self.coordinator?.sortObjectsByDate(in: self.tableView ?? UITableView(), in: self, with: self.timePeriod ?? currentEra)
            self.tableView?.reloadData()
        }),
                       UIAction(title: "By category", handler: { _ in
            self.sortByDates = false
            self.coordinator?.sortObjectsByCategory(in: self.tableView ?? UITableView(), in: self, with: self.timePeriod ?? currentEra)
            self.tableView?.reloadData()
            
        })]
        
        sortMethodSelectionButton.menu = UIMenu(children: actions)
        coordinator?.sortObjectsByDate(in: tableView ?? UITableView(), in: self, with: timePeriod ?? currentEra)
    }
    
    // this category button opens categories VC
    private func setupCategoryButton() {
        let actions = [UIAction(title: "Category list", handler: { _ in
            self.delegate?.mainOperationsVCdidTapCategoriesButton(vc: self)
        })]
        categoriesButton.menu = UIMenu(children: actions)
    }

    private func setUpTableView() {
        
        let tableView = UITableView(frame: containerView.frame, style: .grouped)
        self.tableView = tableView
        guard tableView == tableView else { return }
        containerView.addSubview(tableView)
        tableView.fillSuperview()
        tableView.delegate = self
    }
    
    // tells its dataSource, what time period it must prepare
    @IBAction func timePeriodSelected(_ sender: UISegmentedControl) {
        
        let currentDate = Date()
        let currentEra = Calendar.current.dateComponents([.era], from: currentDate)
        if sender.selectedSegmentIndex == 0 {
            timePeriod = Calendar.current.dateComponents([.era], from: currentDate)
            timePeriodLabel.text = ""
        } else if sender.selectedSegmentIndex == 1 {
            timePeriod = Calendar.current.dateComponents([.day, .month, .year], from: currentDate)
            timePeriodLabel.text = "today"
        } else if sender.selectedSegmentIndex == 2 {
            timePeriod = Calendar.current.dateComponents([.weekOfYear, .year], from: currentDate)
            timePeriodLabel.text = "this week"
        } else if sender.selectedSegmentIndex == 3 {
            timePeriod = Calendar.current.dateComponents([.year, .month], from: currentDate)
            timePeriodLabel.text = "this month"
        } else if sender.selectedSegmentIndex == 4 {
            timePeriod = Calendar.current.dateComponents([.year], from: currentDate)
            timePeriodLabel.text = "this year"
        }
        coordinator?.timePeriodChanged(to: timePeriod ?? currentEra)
        tableView?.reloadData()
    }
    
    
    private func fillMoneyLabels() {
        guard moneyAccount == moneyAccount else { return }
        guard totalSpent == totalSpent else { return }
        spentMoneyLabel.text = "\(totalSpent ?? 0.0) \(moneyAccount.currency )"
        currentBalanceLabel.text = "\(moneyAccount.currentBalance )"
    }
    
    private func makeDateStringOf(date: Date, with dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    @IBAction func didTapAddOperationButton(_ sender: UIButton) {
        delegate?.mainOperationsVCDidTapAddButton(vc: self)
    }
    
}


extension MainOperationsViewController: UITableViewDelegate {
    
    // switch here to be able to open operation both when i sort by dates and by category
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch sortByDates {
        case true:
            guard let currentKey = sortedByDateKeysArray?[indexPath.section] else { return }
            guard let moneyOperation = sortedByDateOperations?[currentKey]?[indexPath.row] else { return }
            let selectedOperation = moneyOperation
            delegate?.mainOperationsVC(vc: self, didTap: selectedOperation)
        case false:
            guard let currentKey = sortedByCategoryKeysArray?[indexPath.section] else { return }
            guard let moneyOperation = sortedByCategoryOperations?[currentKey]?[indexPath.row] else { return }
            let selectedOperation = moneyOperation
            delegate?.mainOperationsVC(vc: self, didTap: selectedOperation)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerString = ""
        
        // tell dataSource that section was tapped. It is made to open and close section's rows (in this case through dataSourceeCoordinator and i think it was not the best idea but it is too late)
        let frame = CGRect(x: ViewConfig.kHeaderViewOriginX, y: 0, width: ViewConfig.kHeaderViewWidth, height: ViewConfig.kHeaderViewHeight)
        let action = UIAction {_ in
            self.coordinator?.vcDidTapSectionHeader(in: section)
            tableView.reloadData()
        }
        let button = UIButton(frame: frame, primaryAction: action)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemGray4
        
        
        switch sortByDates {
        case true:
            if timePeriod != Calendar.current.dateComponents([.year], from: Date()) {
                guard let key = sortedByDateKeysArray?[section] else { return nil }
                headerString = makeDateStringOf(date: key, with: "dd MMMM yyyy")
            } else {
                guard let key = sortedByDateKeysArray?[section] else { return nil }
                headerString = makeDateStringOf(date: key, with: "MMMM yyyy")
            }
        case false:
            guard let key = sortedByCategoryKeysArray?[section] else { return nil }
            headerString = key
        }
        
        button.setTitle(headerString, for: .normal)

        let headerView: UIView = UIView(frame: CGRect(x: ViewConfig.kHeaderViewOriginX, y: 0, width: frame.size.width, height: frame.size.height))
        headerView.addSubview(button)
        
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ViewConfig.kHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return ViewConfig.kFooterHeight
    }

}


extension MainOperationsViewController: OperationEditorVCDelegate {
    func operationEditorVCeditedOperation(vc: UIViewController, old: OperationObject, new: OperationObject) {
        persistenceManager.saveEditedOperation(old: old, new: new, in: moneyAccount)
        fillMoneyLabels()
        tableView?.reloadData()
    }

    func operationEditorVC(vc: UIViewController, didAdd newOpp: OperationObject, with category: CategoryObject) {
        persistenceManager.saveNewOperation(newOpp, in: moneyAccount)
        tableView?.reloadData()
    }
    
    
}

extension MainOperationsViewController: SortedByDateDataSourceDelegate {
    func showAlertController(ac: UIAlertController) {
        present(ac, animated: true)
    }
    
    func operationIsDeleted(operation: OperationObject) {
        self.persistenceManager.deleteOperation(operation, from: self.moneyAccount)
    }
    
    func setSortedOperations(dict: [Date : [OperationObject]], and keys: [Date], expenses sum: Double) {
        self.sortedByDateOperations = dict
        self.sortedByDateKeysArray = keys
        self.totalSpent = sum
        fillMoneyLabels()
    }
}

extension MainOperationsViewController: SortedByCategoryDataSourceDelegate {
    func setSortedOperations(dict: [String : [OperationObject]], and keys: [String], expenses sum: Double) {
        self.sortedByCategoryOperations = dict
        self.sortedByCategoryKeysArray = keys
        self.totalSpent = sum
        fillMoneyLabels()
    }
    
    
}

extension MainOperationsViewController: CategoriesViewControllerDelegate {
    func categoriesVCDidTapNewCategory(vc: CategoriesViewController) {
        delegate?.mainOperationsVCDidTapNewCategory(vc: vc)
    }
    
    func categoryVC(vc: CategoriesViewController, didTapEdit category: CategoryObject) {
        delegate?.mainOperationsVC(vc: vc, didTapEdit: category)
    }
    
}

