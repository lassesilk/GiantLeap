//
//  InfoViewController.swift
//  GiantLeap
//
//  Created by Lasse Silkoset on 19.06.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import UIKit
import MapKit

class InfoViewController: UIViewController {
    
    var infoArray = [ItemObject]()

    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var phonenrLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phonenrTextView: UITextView!
    @IBOutlet weak var addressTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = infoArray[0].name
//        textViewOutlet.insertText(infoArray[0].adresse!)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
