//
//  ViewController.swift
//  GoToJailSwift
//
//  Created by Jonathan Kilgore on 2/3/16.
//  Copyright © 2016 Jonathan Kilgore. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var textView: UITextView!
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }



    @IBAction func startViolatingPrivacy(sender: AnyObject) {
        
        locationManager.startUpdatingLocation()
        textView.text = "Locatiing YOU..."
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        if location?.verticalAccuracy < 1000 && location?.horizontalAccuracy < 1000 {
            textView.text = "Location found, sucka!! Reverse Geocoding..."
            reverseGeocode(location!)
            locationManager.stopUpdatingLocation()
            
        }
    }
    
    func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            let placemark = placemarks?.first
            let address = "\(placemark!.subThoroughfare!) \(placemark!.thoroughfare!) \n\(placemark!.locality!)\n\(placemark!.subLocality!)"
            self.textView.text = "Found you: \(address)"
            self.findJailNear(location)
            
        }
    }
    
    func findJailNear(location: CLLocation) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "Correctional"
        request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1))
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response: MKLocalSearchResponse?, error: NSError?) -> Void in
            let mapItems = response?.mapItems
            let mapItem = mapItems?.first
            self.textView.text = "Go directly to \(mapItem!.name!)"
            self.getDirectionsTo(mapItem!)
        }
    }
    
    func getDirectionsTo(destinationItem: MKMapItem) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = destinationItem
        
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler { (response: MKDirectionsResponse?, error: NSError?) -> Void in
            let routes = response?.routes
            let route = routes?.first
            
            var x = 1
            let directionsString = NSMutableString()
            
            for step in route!.steps {
                directionsString.appendString("\(x): \(step.instructions)\n")
                x++
            }
            
            self.textView.text = directionsString as String
        }
    }

    
    
    
//end of class
}

