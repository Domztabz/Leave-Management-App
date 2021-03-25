//
//  VisitorsDetailViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 04/02/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import Kingfisher

class VisitorsDetailViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var company: UILabel!
    
    @IBOutlet weak var timeIn: UILabel!
    
    @IBOutlet weak var timeOut: UILabel!
    
    @IBOutlet weak var reason: UILabel!
    
    var visitor: MyVisitor?
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        profileImage.layer.borderWidth = 3
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = #colorLiteral(red: 0.9115932642, green: 0.9115932642, blue: 0.9115932642, alpha: 1)
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        if let _visitor = visitor {
            let firstName: String = (_visitor.visitor?.fname)!
            let secondName: String = (_visitor.visitor?.lname)!
            
            name.text = firstName + " " + secondName
            phone.text = _visitor.visitor?.phone
            company.text = _visitor.visitor?.company_name
            timeIn.text = _visitor.time_in
            timeOut.text = _visitor.time_out
            reason.text = _visitor.reason
            
            if let url_ = _visitor.visitor?.avatar {
                let url = URL(string: "http://portal.adriankenya.work/api" + url_)
                profileImage.kf.setImage(with: url)
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

}
