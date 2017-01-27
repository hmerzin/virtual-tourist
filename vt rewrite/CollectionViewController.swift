//
//  CollectionViewController.swift
//  vt rewrite
//
//  Created by Harry Merzin on 1/22/17.
//  Copyright © 2017 Harry Merzin. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreData

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var pin: Pin?
    
    var gotCount = false
    
    var images = [Image]()
    
    var selectedImages = [Image]()
    
    let networking = NetworkingClient.sharedinstance
    
    override func viewDidLoad() {
        centerMapOnLocation(location: CLLocationCoordinate2D(latitude: CLLocationDegrees(pin!.latitude), longitude: CLLocationDegrees(pin!.longitude)))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 7.0, left: 15.0, bottom: 100.0, right: 15.0) //http://icodeswift.com/uicollectionview-spacing/
        fetchImages()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "count"), object: nil, queue: nil, using: { notification in
            self.gotCount = true
            self.collectionView.reloadData()
        })
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "downloaded"), object: nil, queue: nil, using: { notification in
            print("fired:")
            self.fetchImages()
            self.collectionView.reloadData()
        })
        collectionView.allowsMultipleSelection = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        cell.selectedIndicator.isHidden = true
        cell.activityIndicator.hidesWhenStopped = true
        if(images.indices.contains(indexPath.row)) {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = UIImage(data: self.images[indexPath.row].image as! Data)
            return cell
        } else {
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(Int((pin?.imagesCount)!) <= 12) {
            return Int((pin?.imagesCount)!)
        } else {
            return 12
        }
    }
    
    final let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(coordinateRegion, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees((pin?.latitude)!), longitude: CLLocationDegrees((pin?.longitude)!))
        mapView.addAnnotation(annotation)
    }
    
    private func fetchImages() {
        let imagesFetch = NSFetchRequest<Image>(entityName: "Image")
        imagesFetch.predicate = NSPredicate(format: "pin = %@", argumentArray: [self.pin!])
        do {
            self.images = try self.context.fetch(imagesFetch)
        } catch {
            fatalError("could not fetch images")
        }

        print("fetched count: \(self.images.count)")
    }
    


    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        images.forEach({ image -> Void in
            context.delete(image)
            do {
                try context.save()
            } catch {
                fatalError("couldn't delete images")
            }
        })
        networking.getImageFromFlickr(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees((pin?.latitude)!), longitude: CLLocationDegrees((pin?.longitude)!)), pin: self.pin!, page: Int(self.pin!.page) + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CustomCell
        if(images.indices.contains(indexPath.row)){
            selectedImages.append(images[indexPath.row])
            cell.selectedIndicator.isHidden = false
            print(selectedImages.count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedImages.remove(at: selectedImages.index(of: images[indexPath.row])!)
        let cell = collectionView.cellForItem(at: indexPath) as! CustomCell
        cell.selectedIndicator.isHidden = true
    }
    
    @IBAction func deleteImages(_ sender: Any) {
        pin?.imagesCount = (pin?.imagesCount)! - Double(selectedImages.count)
        selectedImages.forEach({image -> Void in
            selectedImages.removeAll()
            context.delete(image)
        })
        
        do {
            try context.save()
        } catch {
            fatalError("couldn't save context")
        }
        fetchImages()
        collectionView.reloadData()
    }

}
