//
//  NetworkingClient.swift
//  vt rewrite
//
//  Created by Harry Merzin on 1/21/17.
//  Copyright © 2017 Harry Merzin. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class NetworkingClient {
    static let sharedinstance = NetworkingClient()
    let networking = Networking()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    func getImageFromFlickr(coordinate: CLLocationCoordinate2D, pin: Pin, page: Int) {
        networking.getImagesForLocation(coordinate: coordinate, page: page, completion: { (dict) -> Void in
            pin.imagesCount = Double((dict?.count)!)
            let notification = Notification(name: Notification.Name(rawValue: "count"))
            NotificationCenter.default.post(notification)
            for item in dict! {
                let id = item["id"]
                print("id:", id)
                self.networking.getImageURLById(imageId: id! as! String, completion: {url -> Void in
                    self.networking.downloadImageFromSource(imageSource: url as! String!, completion: {data in
                        let image = Image(entity: NSEntityDescription.entity(forEntityName: "Image", in: self.context)!, insertInto: self.context)
                        image.image = data as NSData?
                        if(pin.managedObjectContext != nil) {
                            image.pin = pin
                            do {
                                try self.context.save()
                            } catch {
                                fatalError("couldn't save")
                            }
                        }
                        let notification = Notification(name: Notification.Name(rawValue: "downloaded"))
                        NotificationCenter.default.post(notification)
                    })
                })
            }
        })
    }
}
