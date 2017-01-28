//
//  ViewController.swift
//  vt rewrite
//
//  Created by Harry Merzin on 1/21/17.
//  Copyright © 2017 Harry Merzin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let networkingClient = NetworkingClient.sharedinstance
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var deleteMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        var pinsArray: [Pin]
        do {
            pinsArray = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            fatalError("couldn't fetch")
        }

        let annotations = pinsArray.map({pin -> PinWrapper in
            return PinWrapper(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude)), pin: pin)
        })
        mapView.addAnnotations(annotations)
    }
    
    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            print("pressed")
            let touchPoint = sender.location(in: self.mapView)
            let coord: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let pin = Pin(entity: NSEntityDescription.entity(forEntityName: "Pin", in: appDelegate.persistentContainer.viewContext)!, insertInto: appDelegate.persistentContainer.viewContext)
            let annotation = PinWrapper(coordinate: coord, pin: pin)
            pin.latitude = Double(coord.latitude)
            pin.longitude = Double(coord.longitude)
            networkingClient.getImageFromFlickr(coordinate: coord, pin: pin, page: 1)
            mapView.addAnnotation(annotation)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = (view.annotation as! PinWrapper).pin
        if(!deleteMode) {
            print("pressed")
            let destinationVC = storyboard?.instantiateViewController(withIdentifier: "CollectionVC") as! CollectionViewController
            destinationVC.pin = pin
            self.present(destinationVC, animated: true)
        } else {
            self.appDelegate.persistentContainer.viewContext.delete(pin)
            do {
                try self.appDelegate.persistentContainer.viewContext.save()
            } catch {
                fatalError("could not save")
            }
            mapView.removeAnnotation(view.annotation!)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinView")
        view.animatesDrop = true
        return view
    }
    
    @IBOutlet weak var deleteModeView: UIView!
    
    @IBAction func deleteMode(_ sender: Any) {
        deleteModeView.isHidden = !deleteModeView.isHidden
        self.deleteMode = !self.deleteMode
        
    }
}

