//
//  CalendarView.swift
//  Calendar
//
//  Created by Lancy on 02/06/15.
//  Copyright (c) 2015 Lancy. All rights reserved.
//

import UIKit

// 12 months - base date - 12 months
let kMonthRange = 12

@objc protocol CalendarViewDelegate: class {
    func didSelectDate(_ date: Foundation.Date)
    optional func didChangeSelectedDates(_ selectedDates: [Foundation.Date])
}

class CalendarView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, MonthCollectionCellDelegate {
    
    @IBOutlet var monthYearLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    weak var delegate: CalendarViewDelegate?

    fileprivate var collectionData = [CalendarLogic]()
    var baseDate: Foundation.Date? {
        didSet {
            collectionData = [CalendarLogic]()
            if baseDate != nil {
                var dateIter1 = baseDate!, dateIter2 = baseDate!
                var set = Set<CalendarLogic>()
                set.insert(CalendarLogic(date: baseDate!))
                // advance one year
                for var i = 0; i < kMonthRange; i++ {
                    dateIter1 = dateIter1.firstDayOfFollowingMonth
                    dateIter2 = dateIter2.firstDayOfPreviousMonth
                    
                    set.insert(CalendarLogic(date: dateIter1))
                    set.insert(CalendarLogic(date: dateIter2))
                }
                collectionData = Array(set).sorted(by: <)
            }
            
            updateHeader()
            collectionView.reloadData()
        }
    }
    
    var selectedDates: [Foundation.Date] = [Foundation.Date]() {
        didSet {
            collectionView.reloadData()
            DispatchQueue.main.async{
                self.moveToSelectedDate(false)
                if self.delegate != nil && self.selectedDates.count > 0 {
                    self.delegate!.didSelectDate(self.selectedDates.last!)
                    self.delegate!.didChangeSelectedDates?(self.selectedDates)
                }
            }
        }
    }

    var allowMultipleSelections = false
    
    override func awakeFromNib() {
        let nib = UINib(nibName: "MonthCollectionCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "MonthCollectionCell")
    }
    
    class func instance(_ baseDate: Foundation.Date, selectedDate: Foundation.Date) -> CalendarView {
        return instance(baseDate, selectedDates: [selectedDate])
    }
    
    class func instance(_ baseDate: Foundation.Date, selectedDates: [Foundation.Date]) -> CalendarView {
        let calendarView = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil).first as! CalendarView
         selectedDates.forEach({ (date) -> () in
            calendarView.selectedDates.append(date.startOfDay)
        })
        if calendarView.selectedDates.count == 0 {
            calendarView.selectedDates.append(Foundation.Date().startOfDay)
        }
        calendarView.baseDate = baseDate
        return calendarView
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCollectionCell", for: indexPath) as! MonthCollectionCell
        
        cell.monthCellDelgate = self
        
        cell.logic = collectionData[indexPath.item]
        cell.selectedDates.removeAll()
        for date in selectedDates {
            if cell.logic!.isVisible(date) {
                cell.selectedDates.append(Date(date: date))
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            updateHeader()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateHeader()
    }
    
    func updateHeader() {
        let pageNumber = Int(collectionView.contentOffset.x / collectionView.frame.width)
        updateHeader(pageNumber)
    }
    
    func updateHeader(_ pageNumber: Int) {
        if collectionData.count > pageNumber {
            let logic = collectionData[pageNumber]
            monthYearLabel.text = logic.currentMonthAndYear as String
        }
    }
    
    @IBAction func retreatToPreviousMonth(_ button: UIButton) {
        advance(-1, animate: true)
    }
    
    @IBAction func advanceToFollowingMonth(_ button: UIButton) {
        advance(1, animate: true)
    }
    
    func advance(_ byIndex: Int, animate: Bool) {
        var visibleIndexPath = self.collectionView.indexPathsForVisibleItems.first as IndexPath!
        
        if (visibleIndexPath.item == 0 && byIndex == -1) ||
           ((visibleIndexPath.item + 1) == collectionView.numberOfItems(inSection: 0) && byIndex == 1) {
           return
        }
        
        visibleIndexPath = IndexPath(item: visibleIndexPath.item + byIndex, section: visibleIndexPath.section)
        updateHeader(visibleIndexPath.item)
        collectionView.scrollToItem(at: visibleIndexPath, at: .centeredHorizontally, animated: animate)
    }
    
    func moveToSelectedDate(_ animated: Bool) {
        var index = -1
        for var i = 0; i < collectionData.count; i++  {
            let logic = collectionData[i]
            if selectedDates.count > 0 && logic.containsDate(selectedDates.last!) {
                index = i
                break
            }
        }
        
        if index != -1 {
            let indexPath = IndexPath(item: index, section: 0)
            updateHeader(indexPath.item)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        }
    }
    
    //MARK: Month cell delegate.
    func didSelect(_ date: Date) {
        if !allowMultipleSelections {
            selectedDates[0] = date.nsdate.startOfDay
        }
        else {
            selectedDates.append(date.nsdate.startOfDay)
        }
    }
    
    func didDeselect(_ date: Date) {
        if selectedDates.count == 1 {
            return
        }
        
        for aDate in selectedDates {
            if aDate.isSameDay(date.nsdate.startOfDay) {
                if let index = selectedDates.index(of: aDate) {
                    selectedDates.remove(at: index)
                }
            }
        }
    }
}
