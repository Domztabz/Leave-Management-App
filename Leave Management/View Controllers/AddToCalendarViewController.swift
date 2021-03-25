//
//  AddToCalendarViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 10/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit
import EventKit

class AddToCalendarViewController: UIViewController {
    
    var savedEventId: String?

    @IBOutlet weak var cardView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cardView.setCardView(view: cardView)
    }
    

    @IBAction func addToCalendar(_ sender: RoundedButton) {
    
        let store = EKEventStore()
        store.requestAccess(to: .event) {(granted, error) in
            if !granted { return }
            var event = EKEvent(eventStore: store)
            event.title = "Event Title"
            event.startDate = NSDate() as Date //today
            event.endDate = (event.startDate + 60*60) as Date //1 hour long meeting
            event.calendar = store.defaultCalendarForNewEvents
            do {
                try store.save(event, span: .thisEvent, commit: true)
                self.savedEventId = event.eventIdentifier //save event id to access this particular event later
            } catch {
                // Display error to user
            }
        }


    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        })
    }

}
extension UIView {
    
    func setCardView(view : UIView){
        view.layer.cornerRadius = 5.0
        view.layer.borderColor  =  UIColor.clear.cgColor
        view.layer.borderWidth = 5.0
        view.layer.shadowOpacity = 0.5
        view.layer.shadowColor =  UIColor.lightGray.cgColor
        view.layer.shadowRadius = 5.0
        view.layer.shadowOffset = CGSize(width:5, height: 5)
        view.layer.masksToBounds = true
        
    }
}
