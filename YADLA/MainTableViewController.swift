//
//  MainTableViewController.swift
//  YACTA
//
//  Created by MAC on 25/11/2019.
//  Copyright © 2019 Gera Volobuev. All rights reserved.
//

import UIKit


class MainTableViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    let sharedDefaults = UserDefaults(suiteName:
        "group.todayExtensionYACTA")
    var remindersArray = [String]() {
        didSet {
            sharedDefaults?.setValue(remindersArray, forKey: "newEntry")
            defaults.setValue(remindersArray, forKey: "oldArray")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "YADLA"
        
        registerLocal()
        
        // custom table view
        self.registerTableViewCells()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        // :NAVIGATION BAR BUTTONS //
        
        // try using SF symbol for add button
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(pushDateEdit))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(pushDateEdit))
        }
        
        // check if user stored any data previously and insert it
        let data = defaults.value(forKey: "oldArray")
        if data != nil {
            remindersArray = data as! Array
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil )
    }
    
    
    @objc func appBecomeActive() {
        tableView.reloadData()
    }
    // push to next view for adding reminder
    @objc func pushDateEdit() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Date") as? DateViewController {
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // add new entry to array
    func addDate(newDate: String) {
        remindersArray.append(newDate)
        tableView.reloadData()
        let splittedDate = newDate.components(separatedBy: "\n")
        //        let date = String(daysLeft(days: splittedDate[1]))
        scheduleLocal(title: splittedDate[0], body: splittedDate[1])
    }
    
    // edit existing array entry
    func editDate(newDate: String, oldDate: String) {
        if let row = remindersArray.firstIndex(where: {$0 == oldDate}) {
            remindersArray[row] = newDate
            tableView.reloadData()
        }
    }
    
    // register custom table cell
    func registerTableViewCells() {
        let customCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(customCell, forCellReuseIdentifier: "CustomTableViewCell")
    }
    
    // calculate number of days left from reminer's date entry
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
    
    
    // MARK: - Notifications
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Yay")
            } else {
                print("Douh")
            }
        }
    }
    
    @objc func scheduleLocal(title: String, body: String) {
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "alarm"
        content.sound = .default
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let date = dateFormatter.date(from: body)

        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date!)
        
        var dateComponets = DateComponents()
        dateComponets.hour = 19
        dateComponets.minute = 30
        dateComponets.year = components.year
        dateComponets.month = components.month
        dateComponets.day = components.day
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponets, repeats: true)
        //            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false) // for debuging
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindersArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? CustomTableViewCell  else { fatalError("Unable to dequeue cell") }
        
        // Get user date+reminder as item
        let date = remindersArray[indexPath.row]
        // split item array in two seperating it by new line
        let splittedDate = date.components(separatedBy: "\n")
        // use daysLeft() on item date and place it in detailLabel
        cell.daysLeftLabel?.text = String(daysLeft(days: splittedDate[1]))
        cell.dateLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        // Color the reminder title
        let headerColor = date
        let footerColor = splittedDate[0]
        let range = (headerColor as NSString).range(of: footerColor)
        let coloredResult = NSMutableAttributedString.init(string: headerColor)
        coloredResult.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.9960784314, green: 0.3764705882, blue: 0.3254901961, alpha: 1), range: range)
        
        cell.dateLabel?.attributedText = coloredResult
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, complete in
            self.remindersArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            complete(true)
        }
        UIButton.appearance().setTitleColor(#colorLiteral(red: 0.9960784314, green: 0.3764705882, blue: 0.3254901961, alpha: 1), for: UIControl.State.normal)
        deleteAction.title = "DELETE"
        deleteAction.backgroundColor = .white
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let DVC = storyboard?.instantiateViewController(withIdentifier: "Date") as? DateViewController {
            DVC.delegate = self
            navigationController?.pushViewController(DVC, animated: true)
            DVC.cellForEdit.append(remindersArray[indexPath.row])
            DVC.cellForEdit.append(String(indexPath.row))
            
        }
    }
}
