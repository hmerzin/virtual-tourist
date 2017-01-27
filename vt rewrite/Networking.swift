//
//  Networking.swift
//  vt rewrite
//
//  Created by Harry Merzin on 1/21/17.
//  Copyright © 2017 Harry Merzin. All rights reserved.
//

import Foundation
import CoreLocation

class Networking {
    let apiKey = "5c2486f22855f203ad37f713d8415dc1"
    var perPage = 12
    func getImagesForLocation(coordinate: CLLocationCoordinate2D, page: Int, completion: @escaping (_ dict: [[String:AnyObject]]?) -> Void) {
        print(coordinate)
        var request = URLRequest(url: URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&per_page=\(perPage)&page=\(page)&format=json&nojsoncallback=1")!)
        request.httpMethod = "GET"
        let session = URLSession.shared // swift request help from: https://grokswift.com/updating-nsurlsession-to-swift-3-0/
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error == nil {
                //print(data)
                var parsedResult: AnyObject?
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject? // http://stackoverflow.com/questions/39423367/correctly-parsing-json-in-swift-3
                } catch let error as NSError {
                    print(error)
                    completion(nil)
                    return
                }
                //print(parsedResult)
                let results = parsedResult?["photos"] as? [String: AnyObject]
                print(results)
                let photo = results?["photo"] as? [[String: AnyObject]]
                //print(photo)
                completion(photo)
                
            }
        }).resume()
    }
    
    func getImageURLById(imageId: String, completion: @escaping (_ imageSource: String?) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=\(apiKey)&photo_id=\(imageId)&format=json&nojsoncallback=1")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, reponse, error) in
            if error == nil {
                //print(data)
                var parsedResult: AnyObject?
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject? // http://stackoverflow.com/questions/39423367/correctly-parsing-json-in-swift-3
                } catch let error as NSError {
                    print(error)
                    completion(nil)
                    return
                }
                print(parsedResult)
                //print(parsedResult)
                let sizes = parsedResult?["sizes"] as? [String: AnyObject]
                let size = sizes?["size"] as? [[String: AnyObject]]
                let square = size?[0] as [String: AnyObject]!
                let source = square?["source"]
                print("source:", source)
                completion(source as! String?)
            }
        }).resume()
    }
    
    func downloadImageFromSource(imageSource: String?, completion: @escaping (_ imageData: Data) -> Void) {
        // on completion append to array that gets passed to the collection view controller  (set image)?
        // call download methods in appdelegate becuase it never gets deallocated
        let queue  = DispatchQueue(label: "newQueue")
        let main = DispatchQueue.main
        queue.async {
            do {
                let data = try Data(contentsOf: URL(string: imageSource!)!)
                main.sync {
                    completion(data)
                }
                
            } catch let error as NSError {
                print(error)
                return
            }
            catch {
                // http://stackoverflow.com/questions/30826560/swift-2-invalid-conversion-from-throwing-function-of-type-to-non-throwing-funct
            }
        }
    }

}
