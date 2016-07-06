//
//  City.swift
//  SwanWeather
//
//  Created by EDGARDO AGNO on 05/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import RealmSwift

class Main: Object {
    dynamic var temp = 0.0
    dynamic var temp_min = 0.0
    dynamic var temp_max = 0.0
}

class Coordinate : Object {
    dynamic var lon : Double = 0
    dynamic var lat : Double = 0
}

class Sys : Object {
    dynamic var country = ""
    dynamic var sunrise = 0
    dynamic var sunset = 0
}

class Weather: Object {
    dynamic var main = ""
    dynamic var description2 = ""
    dynamic var icon = ""
}

class City: Object {
    dynamic var id = 0
    dynamic var lastupdate : NSDate? = nil
    dynamic var name  = ""
    dynamic var dt = 0
    dynamic var main : Main?
    dynamic var coord : Coordinate?
    dynamic var sys : Sys?
    let weather = List<Weather>()
    var forecasts = List<Forecast>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }    
}
