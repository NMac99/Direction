//
//  ViewController.swift
//  Direction
//
//  Created by Narek Arsenyan on 01.10.21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var textFieldForAdress: UITextField!
    @IBOutlet weak var getDirectionButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        map.delegate = self
    }

    @IBAction func getDirectionTapped(_ sender: Any) {
        getAdress()
    }
    func getAdress() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textFieldForAdress.text!) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                print("No location found")
                return
            }
            print(location)
            self.mapThis(destantionCord: location.coordinate)
        }
    }
    
    func  locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func mapThis(destantionCord: CLLocationCoordinate2D) {
        let sourceCordinate = locationManager.location?.coordinate
        let soucePlaceMark = MKPlacemark(coordinate: sourceCordinate!)
        let destPlaceMark = MKPlacemark(coordinate: destantionCord)
        let sourceItem = MKMapItem(placemark: soucePlaceMark)
        let destItem = MKMapItem(placemark: destPlaceMark)
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        let direction = MKDirections(request: destinationRequest)
        direction.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Something is wrong :(")
                }
                return
            }
            
            let route = response.routes[0]
            self.map.addOverlay(route.polyline)
            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
}

