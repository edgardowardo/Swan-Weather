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
import Alamofire

class CityViewModel {

    var realm : Realm! = try? Realm()
    var disposeBag = DisposeBag()
    var current: Variable<City?> = Variable(nil)
    var hudDelegate : HudDelegate?
    private var cityid : Int
    
    init(cityid : Int) {
        self.cityid = cityid
    }
    
    var city : String {
        if let t = current.value?.name {
            return t
        }
        return ""
    }
    
    var temperature : String {
        if let t = current.value?.main?.temp {
            return "\(Int(t))°"
        }
        return ""
    }
    
    var clouds : String {
        if let t = current.value?.weather.first?.main {
            return t
        }
        return ""
    }
    
    var temperatureMin : String {
        if let t = current.value?.main?.temp_min {
            return "\(Int(t))°"
        }
        return ""
    }

    var cloudsIcon : String {
        if let t = current.value?.weather.first?.icon {
            return t
        }
        return ""
    }
    
    func refreshCity(withCallBack : (()->Void)? = nil ) {
        var current : City? = nil
        if let first = realm.objects(City).filter("id == \(self.cityid)").first {
            current = first
        }
        
        // Current data is not stale. That is  it's less than half an hour, show this data.
        if let c = current, lastupdate = c.lastupdate where NSDate().timeIntervalSinceDate(lastupdate) / 3600 < 0.5 {
            self.current.value = c
        } else {
            self.hudDelegate?.showHud(text: "Searching...")

            OpenWeatherMapService.fetchCityAndForecast(withId: self.cityid, callback: { (city, forecasts) in
                autoreleasepool {
                    try! self.realm.write {
                        city.lastupdate = NSDate()
                        city.forecasts = forecasts.list
                        self.realm.add(city, update: true)
                    }
                }
                self.current.value = city
                self.hudDelegate?.hideHud()
                if let callback = withCallBack {
                    callback()
                }
            })
        }
    }
}
