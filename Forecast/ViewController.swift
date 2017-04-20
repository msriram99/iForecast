//
//  ViewController.swift
//  Forecast
//
//  Created by Himaja Motheram on 4/14/17.
//  Copyright © 2017 Sriram Motheram. All rights reserved.
//


import UIKit
import MapKit
    

    class ViewController: UIViewController, MKMapViewDelegate {
        
        
        @IBOutlet weak var SearchButton: UIButton!
        @IBOutlet weak var locationSearchBar: UISearchBar!
        
        @IBOutlet weak var TempLabel: UILabel!
    
        @IBOutlet weak var IconLabel: UILabel!
        
       
        @IBOutlet weak var IconImage: UIImageView!
        @IBOutlet weak var SummaryLabel: UILabel!
        
        var locationMgr = CLLocationManager()
        
        var location = Location()
        var currentWeather = Weather()
        
        
        
        let key = "2bb7372745503098aa8748f50e0c9007"
        let hostName = "https://api.darksky.net/forecast"
        
        //var skycons = Skycons( )
        //MARK: - Gecoding Methods
        
        func addLocAndPinFor(placemarks: [CLPlacemark]?, title: String) {
            guard let placemarks = placemarks, let placemark = placemarks.first else {
                return
            }
            
            //print ("\(placemark)")
    
            location = Location(name: title,  lat: placemark.location!.coordinate.latitude, lon: placemark.location!.coordinate.longitude)
           
            WeatherSearch()
            
}
        
        func latlonSearch() {
           locationSearchBar.resignFirstResponder()
            guard let searchText = locationSearchBar.text, let loc = locationFrom(string: searchText) else {
                return
            }
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(loc) { (placemarks, error) in
                if let err = error {
                    print("Got Error \(err.localizedDescription)")
                } else {
                    self.addLocAndPinFor(placemarks: placemarks, title: "From Lat/Lon: \(searchText)")
                }
            }
        }
        
        func addressSearch() {
            locationSearchBar.resignFirstResponder()
            guard let searchText = locationSearchBar.text else {
                return
            }
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(searchText) { (placemarks, error) in
                if let err = error {
                    print("Got Error \(err.localizedDescription)")
                } else {
                    self.addLocAndPinFor(placemarks: placemarks, title: "From Address: \(searchText)")
                }
            }
        }
        
        func locationFrom(string: String) -> CLLocation? {
            let coordItems = string.components(separatedBy: ",")
            if coordItems.count == 2 {
                guard let lat = Double(coordItems[0]), let lon = Double(coordItems[1]) else {
                    return nil
                }
                return CLLocation(latitude: lat, longitude: lon)
            }
            return nil
        }
        
        //MARK: - Interactivity Methods
    
        
        
        //MARK: - Life Cycle Methods
        override func viewDidLoad() {
            super.viewDidLoad()
            setupLocationMonitoring()
             }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setupLocationMonitoring()
            
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
    }
    
    extension ViewController: CLLocationManagerDelegate {
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let lastLoc = locations.last!
            print("Last Loc: \(lastLoc.coordinate.latitude),\(lastLoc.coordinate.longitude)")
            WeatherSearch()
            manager.stopUpdatingLocation()
        }
        
        //MARK: - Location Authorization Methods
        
        func turnOnLocationMonitoring() {
            locationMgr.startUpdatingLocation()
            
        }
        
        func setupLocationMonitoring() {
            locationMgr.delegate = self
            locationMgr.desiredAccuracy = kCLLocationAccuracyBest
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    turnOnLocationMonitoring()
                case .denied, .restricted:
                    print("Hey turn us back on in Settings!")
                case .notDetermined:
                    if locationMgr.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) {
                        locationMgr.requestAlwaysAuthorization()
                    }
                }
            } else {
                print("Hey Turn Location On in Settings!")
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            setupLocationMonitoring()
        }
        
        @IBAction func searchPressed(button: UIButton) {
            
            print("here")
           //latlonSearch()
            addressSearch()
        }
        
        func reloadData()
        {
            TempLabel.text = ("\(currentWeather.temp)")
            IconLabel.text = currentWeather.icon
            SummaryLabel.text = currentWeather.summary
            IconImage.image = UIImage(named:IconLabel.text!)

        }
        
        
        func WeatherSearch( )
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
          //  https://api.darksky.net/forecast/[key]/[latitude],[longitude]
            
            //let urlString = "\(hostName)/\(key)/\(location.locationLat!),\(location.locationLon!)"
            
            
            let urlString = "\(hostName)/\(key)/\(location.locationLat!),\(location.locationLon!)?exclude=[minutely,hourly,daily,alerts,flags]"
           
           // print(" ***URL\(urlString)")
            
            let url = URL(string: urlString)
            var request = URLRequest(url: url!)
            request.timeoutInterval = 30
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { (data, response, error) in
                guard let recvData = data else {
                    print("No Data")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    return
                }
                if recvData.count > 0 && error == nil {
                    print("Got Data:\(recvData)")
                    let dataString = String.init(data: recvData, encoding: .utf8)
                    print("Got Data String:\(dataString)")
                    self.parseJson(data: recvData)
                } else {
                    print("Got Data of Length 0")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            task.resume()
            
        }
        
        
        func parseJson(data: Data) {
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let resultsArray = jsonResult as! [String:Any]
                print("JSON:\(jsonResult)")
                currentWeather.locationLat = resultsArray["latitude"] as? Double
                currentWeather.locationLon = resultsArray["longitude"] as? Double
                let current = resultsArray["currently"] as? [String:Any]
                 currentWeather.icon = current?["icon"] as? String
                currentWeather.temp = current?["temperature"] as? Int
                
                currentWeather.summary = current?["summary"] as? String
            
               // print("Lat: \(currentWeather.locationLat), Lon: \(currentWeather.locationLon )")
                
               
               // print("\(currentWeather.summary)")
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.reloadData()
                }
                
            } catch {
                print("JSON Parsing Error")
            }
            
            DispatchQueue.main.async {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            }
        }

}
   
