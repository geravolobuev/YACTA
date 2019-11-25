//
//  DateViewController.swift
//  YACTA
//
//  Created by MAC on 25/11/2019.
//  Copyright © 2019 Gera Volobuev. All rights reserved.
//

import UIKit

class DateViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var reminderText: UITextField!
    
       weak var delegate: MainTableViewController?
        
        var userInput: String = ""
        var selectedDate: String = ""
        
        var cellForEdit = [String]()
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.title = "New entry"
            
            // datePicker default todays date
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            let now = Date()
            selectedDate = dateFormatter.string(from: now)
            if #available(iOS 13.0, *) {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(addReminder))
            } else {
                // Fallback on earlier versions
                        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain , target: self, action: #selector(addReminder))
            }

            datePicker.setValue(false, forKey: "highlightsToday")
            // Set some of UIDatePicker properties
            datePicker.timeZone = NSTimeZone.local
            datePicker.backgroundColor = UIColor.white
            // Add an event to call onDidChangeDate function when value is changed.
            datePicker.addTarget(self, action: #selector(DateViewController.datePickerValueChanged(_:)), for: .valueChanged)
            datePicker.datePickerMode = .date
            
            // Focus on the text field when view is active
            reminderText.becomeFirstResponder()
            // Add an event to call onDidChangeDate function when value is changed.
            reminderText.addTarget(self, action: #selector(addReminder), for: .touchUpInside)
        }
        
        @objc func datePickerValueChanged(_ sender: UIDatePicker){
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            selectedDate = dateFormatter.string(from: sender.date)
        }
        
        func checkBlankSpace() -> Bool {
            if ((reminderText.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "").isEmpty) {
                let ac = UIAlertController(title: "Empty", message: "Enter title for reminder", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default))
                present(ac, animated: true)
                return false
            } else {
                return true
            }
        }
        
        @objc func addReminder() {
            if checkBlankSpace() == true {
                userInput = "\(reminderText.text!)\n\(selectedDate)"
                if cellForEdit.isEmpty == true {
                    delegate?.addDate(newDate: userInput)
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    delegate?.editDate(newDate: userInput, oldDate: cellForEdit[0])
                    self.navigationController?.popToRootViewController(animated: true)
                    cellForEdit.removeAll()
                }
            }
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    }
