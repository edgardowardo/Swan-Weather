//
//  Router.swift
//  SwanWeather
//
//  Created by EDGARDO AGNO on 06/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = "http://api.openweathermap.org/data/2.5"
    static let appid = "86514c2ae159c18ed4c1908defe97b2d"
    static let mode = "json"
    
    case Search(id : Int)
    case Forecast(id : Int)
    
    // MARK: URLRequestConvertible protocol
    
    var URLRequest: NSMutableURLRequest {
        let result: (path: String, parameters: [String: AnyObject]) = {
            let metric = "metric"
            switch self {
            case .Search(let id) :
                return ("/weather?", ["APPID" : Router.appid, "mode" : Router.mode, "units" : metric, "id" : id])
            case .Forecast(let id) :
                return ("/forecast?", ["APPID" : Router.appid, "mode" : Router.mode, "units" : metric, "id" : id])
            }
        }()
        
        let URL = NSURL(string: Router.baseURLString)!
        let URLRequest = NSURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        let encoding = Alamofire.ParameterEncoding.URL
        
        let e = encoding.encode(URLRequest, parameters: result.parameters).0
        return e
    }
}
