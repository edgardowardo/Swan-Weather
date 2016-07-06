//
//  Forecast.swift
//  SwanWeather
//
//  Created by EDGARDO AGNO on 05/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import RealmSwift

class ForecastMain : Object {
    dynamic var temp : Double = 0
    dynamic var temp_min : Double = 0
    dynamic var temp_max : Double = 0    
}

class Forecast : Object {
    dynamic var dt_txt  = ""
    dynamic var main : ForecastMain?
    let weather = List<Weather>()
}

class Forecasts : Object {
    let list = List<Forecast>()
}
