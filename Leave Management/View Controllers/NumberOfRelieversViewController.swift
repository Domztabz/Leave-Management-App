//
//  NumberOfRelieversViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 16/04/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit

class NumberOfRelieversViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
    }
    
    @IBAction func next(_ sender: RoundedButton) {
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
            switch identifier {
                case "numberOfRelieverSegue" :
                    if self.segmentedControl.selectedSegmentIndex == UISegmentedControl.noSegment {
                        let alert = UIAlertController(title: nil, message: "To continue, please do select the number of relievers.", preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                        return false
                    } else {
                        return true
                    }
            default:
                return false
            }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "numberOfRelieverSegue" :
                if let relieverMVC = segue.destination as? SelectEmployeeViewController {
                    
                    if self.segmentedControl.selectedSegmentIndex == 0 {
                        relieverMVC.limitOfSelections = 1
                    } else if self.segmentedControl.selectedSegmentIndex == 1 {
                        relieverMVC.limitOfSelections = 2
                    } else if self.segmentedControl.selectedSegmentIndex == 2 {
                        relieverMVC.limitOfSelections = 3
                    }
                    
                    }
            default:
                break
            }
        }
    }

}
