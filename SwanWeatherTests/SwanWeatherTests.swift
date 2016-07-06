//
//  SwanWeatherTests.swift
//  SwanWeatherTests
//
//  Created by EDGARDO AGNO on 05/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import XCTest
@testable import SwanWeather

class SwanWeatherTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCityViewModel() {
        
        let id = 2643743 // London town!
        let e = expectationWithDescription("Expect return data from server")
        let vm = CityViewModel(cityid: id)
        XCTAssertEqual(vm.city, "")
        XCTAssertEqual(vm.clouds, "")
        XCTAssertEqual(vm.cloudsIcon, "")
        XCTAssertEqual(vm.temperature, "")
        XCTAssertEqual(vm.temperatureMin, "")
        
        // Clean it first
        try! vm.realm.write({
            for existing in vm.realm.objects(City).filter("id == \(id)") {
                vm.realm.delete(existing)
            }
        })
        
        XCTAssertEqual(vm.realm.objects(City).filter("id == \(id)").count, 0)
        
        vm.refreshCity {
            XCTAssertEqual(vm.city, "London")
            XCTAssertGreaterThan(vm.clouds.characters.count, 0)
            XCTAssertGreaterThan(vm.cloudsIcon.characters.count, 0)
            XCTAssertGreaterThan(vm.temperature.characters.count, 0)
            XCTAssertGreaterThan(vm.temperatureMin.characters.count, 0)
            
            XCTAssertEqual(vm.realm.objects(City).filter("id == \(id)").count, 1)
            
            // Another call to refresh without the call back means it was retrieved from the local datastore!
            vm.refreshCity()
            XCTAssertEqual(vm.city, "London")
            XCTAssertGreaterThan(vm.clouds.characters.count, 0)
            XCTAssertGreaterThan(vm.cloudsIcon.characters.count, 0)
            XCTAssertGreaterThan(vm.temperature.characters.count, 0)
            XCTAssertGreaterThan(vm.temperatureMin.characters.count, 0)
            
            e.fulfill()
        }
        
        waitForExpectationsWithTimeout(60) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}

func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
        if(background != nil){ background!(); }
        
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            if(completion != nil){ completion!(); }
        }
    }
}