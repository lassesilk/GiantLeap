//
//  InfoViewController.swift
//  GiantLeap
//
//  Created by Lasse Silkoset on 19.06.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InfoViewController: UIViewController {
    
    var infoArray = [ItemObject]()
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var webTextView: UITextView!
    @IBOutlet weak var addressTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        
    }
    
    private func setupView() {
        
        nameLabel.text = infoArray[0].name
        descriptionLabel.text = infoArray[0].naering
        
        if let org = infoArray[0].org {
            orgLabel.text = "Orgnr: \(org)"
        }
        
        if let address = infoArray[0].adresse {
            if let postnr = infoArray[0].postnr {
                if let poststed = infoArray[0].poststed {
                    findCoordinates(with: address, and: postnr, and: poststed)
                    addressTextView.isEditable = false
                    addressTextView.dataDetectorTypes = .address
                    addressTextView.insertText("\(address) \(postnr) \(poststed)")
                }
            }
        } else {
            addressLabel.isHidden = true
            addressTextView.isHidden = true
        }
        
        if let web = infoArray[0].hjemmeside {
            webTextView.isEditable = false
            webTextView.dataDetectorTypes = .link
            webTextView.insertText(web)
        } else {
            webLabel.isHidden = true
            webTextView.isHidden = true
        }
    }
    
    private func findCoordinates(with address: String, and postalCode: String, and city: String) {
        let geoCoder = CLGeocoder()
        
        let address = address + postalCode + city
        
        geoCoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            if error != nil {
                print(error!)
            }
            guard let location = placemarks?.first?.location else { return }
            
            let newPin = MKPointAnnotation()
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self?.mapView.setRegion(region, animated: true)
            newPin.coordinate = location.coordinate
            self?.mapView.addAnnotation(newPin)
        }
    }
}
