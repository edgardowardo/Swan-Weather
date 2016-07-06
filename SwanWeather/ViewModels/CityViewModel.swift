//
//  CityViewModel.swift
//  SwanWeather
//
//  Created by EDGARDO AGNO on 05/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class CityViewModel {

    var realm : Realm! = try? Realm()
    var city : City!

    init(city : City) {
        self.city = city
    }
    
}
