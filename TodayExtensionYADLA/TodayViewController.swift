//
//  TodayViewController.swift
//  TodayExtensionYACTA
//
//  Created by MAC on 25/11/2019.
//  Copyright © 2019 Gera Volobuev. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding {
    
    var mainAppArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTableViewCells()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        self.tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        let sharedDefaults = UserDefaults.init(suiteName: "group.todayExtensionYACTA")
        let data = sharedDefaults?.value(forKey: "newEntry")
        mainAppArray = data as! Array
        tableView.reloadData()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let tableSize = CGSize(width: maxSize.width, height: tableView.contentSize.height)
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = tableSize
        }
    }
    
    
    func daysLeft(days: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        guard let date = dateFormatter.date(from: days) else { return 0 }
        let now = Date()
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: now)
        let date2 = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day!
    }
    
    
    // MARK: - Table view data source
    
    func registerTableViewCells() {
        let customCell = UINib(nibName: "CustomWidgetTableCell", bundle: nil)
        self.tableView.register(customCell, forCellReuseIdentifier: "CustomWidgetTableCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainAppArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomWidgetTableCell", for: indexPath) as? CustomWidgetTableCell  else { fatalError("Unable to dequeue cell") }
        let item = mainAppArray[indexPath.row]
        let dayLeftCountVar = item.components(separatedBy: "\n")
        cell.WidgetDaysLeftLabel?.text = String(daysLeft(days: dayLeftCountVar[1]))
        
        // Make reminder title bold
        func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
            let attributedString = NSMutableAttributedString(string: string,
                                                             attributes: [NSAttributedString.Key.font: font])
            let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
            let range = (string as NSString).range(of: boldString)
            attributedString.addAttributes(boldFontAttribute, range: range)
            return attributedString
        }
        
        let boldString = attributedText(withString: item, boldString: dayLeftCountVar[1], font: cell.WidgetDateLabel.font)
        cell.WidgetDateLabel?.attributedText = boldString
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: "YACTAURL://")!
        self.extensionContext?.open(url, completionHandler: { (success) in
            if (!success) {
                print("error: failed to open app from Today Extension")
            }
        })
    }
}
