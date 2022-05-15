//
//  Description.swift
//  WheresMyMoney
//
//  Created by Анна Шербицкая on 2.05.22.
//

import Foundation


///  i think there are no questions with first screen and creation new account
///  on main VC all sections ara tappable and hide its rows in both sorting methods and time periods
///           button in the upper left corner allows you to change account
///           button in the upper right corner allows to choose sorting method
///           segmented control filteres operations by day/week/month etc. and it works for both sorting methods
///           deleting and editing operations is availible in every condition (i mean sorting methods and time periods)
///           button in the lower right corner allows to open category list, where you can create new and edit or delete existing categories. sections on tableView are also tappable


///    UPDATE:  now all sections have footers with total expense/income amount
///            when sorting by date and selected time period is year+, there are not only operations for year shown, but they are grouped by months to make it easier to see your statistics. and total spent sum in left small view is shown for current year.
///            when sorting by category and selected time period is year+, there are only operations for this year
///            operations are sorted correctly, so when now deleting operations while sorting method is by category, it deletes the right operation
///            
