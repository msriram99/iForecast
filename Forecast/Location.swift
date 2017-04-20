//
//  Location.swift
//  Forecast
//
//  Created by Himaja Motheram on 4/14/17.
//  Copyright © 2017 Sriram Motheram. All rights reserved.
//

import Foundation
import UIKit

class Location: NSObject {
    
    var locationName    :String?
  
    var locationLat     :Double?
    var locationLon     :Double?
  //  var enum Icon (clear-day, clear-night, rain, snow, sleet, wind, fog, cloudy, partly-cloudy-day, or partly-cloudy-//night)
    convenience init(name: String, lat: Double, lon: Double) {
        self.init()
        self.locationName = name
        self.locationLat = lat
        self.locationLon = lon
        
       }
    
}



class Weather: NSObject {
    
    var locationName    :String?

    var locationLat     :Double?
    var locationLon     :Double?
    var temp :Int?
    var icon : String?
    var summary : String?
    
    convenience init(name: String, lat: Double, lon: Double, tmp: Int, icon : String, summary: String) {
        self.init()
        self.locationName = name
        self.locationLat = lat
        self.locationLon = lon
        self.temp = tmp
        self.icon = icon
        self.summary = summary
       
    }
    
}
