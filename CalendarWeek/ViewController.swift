//
//  ViewController.swift
//  CalendarWeek
//
//  Created by Markus Bukowski on 08.10.14.
//  Copyright (c) 2014 Markus Bukowski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var weekNumberLabel: UILabel!
    @IBOutlet var dateRangeForWeek: UILabel!
    
    var customDateSelected: Bool = false
    var currentDate: NSDate =
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // bind data to view
        initData()
        
        // listen for the getting active 'callback' to reinitialize the data
        // otherwise data shown could be old. E.g. App is minimized on Sunday 23:59
        // and is reopenened on Monday 00:01. Without reinitialzing data would
        // show values from Sunday and not from Monday.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleWillEnterForeground:"), name: "UIApplicationWillEnterForegroundNotification", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleWillEnterForeground(notification: NSNotification) {
        NSLog("Entering Foreground")
        NSLog("Current locale: %@", NSLocale.currentLocale().localeIdentifier)

        initData()
    }
    
    // calculate and bind data to elements on VIEW
    func initData() {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        // dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("ddMMyyyy", options: 0, locale: NSLocale.currentLocale())
        
        let date: NSDate = NSDate()
        let weekNumber = calculateWeekNumber(date)
        let (dateFrom, dateTo) = calculateDateRangeForWeek(date)
        
        weekNumberLabel.text = "\(weekNumber)"
        dateRangeForWeek.text = "\(dateFormatter.stringFromDate(dateFrom)) - \(dateFormatter.stringFromDate(dateTo))"
    }
    
    // return the week number from a given date
    func calculateWeekNumber(date: NSDate) -> Int {
        var cal: NSCalendar = NSCalendar.currentCalendar()
        return cal.component(NSCalendarUnit.CalendarUnitWeekOfYear, fromDate: date)
    }

    // return the start of week and end of week date for a given date.
    func calculateDateRangeForWeek(date: NSDate) -> (fromDate: NSDate, toDate: NSDate) {
        // create a calendar instance
        let cal: NSCalendar = NSCalendar.currentCalendar()

        // create a new date instance with 'cleared' time based on given date
        let dateWithClearedTime: NSDate = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions.allZeros)
        
        // get the day of the week to calculate how many days have 
        // to be added or deducted
        var dayOfWeek = cal.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: date)
        
        // map the given dayOfWeek to a one that can be used for calculations
        // e.g. Sunday = 1 -> 7
        // e.g. Monday = 2 -> 1
        // e.g. Saturday = 7 -> 6
        let regularDayOfWeek = (dayOfWeek == 1 ? 7 : dayOfWeek-1)
        
        // calculate the days that need to be deducted from the give date to
        // get to the Monday of the week.
        let daysToDeductForFromDate = regularDayOfWeek - 1
        let fromDate = cal.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: -daysToDeductForFromDate, toDate: dateWithClearedTime, options: NSCalendarOptions.allZeros)
        
        // calculate the days that need to be added to the given date so to get
        // the Sunday of the week.
        let daysToAddForToDate = 7 - regularDayOfWeek
        let toDate = cal.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: daysToAddForToDate, toDate: dateWithClearedTime, options: NSCalendarOptions.allZeros)

        return (fromDate: fromDate, toDate: toDate)
    }
    
}

