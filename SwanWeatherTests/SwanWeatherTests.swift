//
//  SwanWeatherTests.swift
//  SwanWeatherTests
//
//  Created by EDGARDO AGNO on 05/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import RealmSwift
import XCTest
@testable import SwanWeather

class SwanWeatherTests: XCTestCase {
    
    let realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Clean the realm first!
        try! realm.write({
            for existing in realm.objects(City) {
                realm.delete(existing)
            }
        })
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSpotService() {

        try! realm.write({
            for existing in realm.objects(Spot) {
                realm.delete(existing)
            }
        })
        
        XCTAssertEqual(realm.objects(Spot).count, 0)
        
        let e = expectationWithDescription("Expect to install Spot data.")
        
        SpotService.loadSpotData { (r) in
            XCTAssertEqual(r.objects(Spot).count, 209579)
            e.fulfill()
        }
        
        waitForExpectationsWithTimeout(60) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testCitiesViewModel() {
        
        let vm = CitiesViewModel()
        XCTAssertEqual(vm.filteredObjects.value.count, 0)
        XCTAssertEqual(vm.currentObjects.value.count, 0)
        
        vm.getCurrentObjects()
        
        XCTAssertEqual(vm.filteredObjects.value.count, 0)
        XCTAssertEqual(vm.currentObjects.value.count, 1)
        XCTAssertEqual(vm.currentObjects.value.first?.0, "RECENTS - 0")
        XCTAssertEqual(vm.currentObjects.value.first?.1.count, 0)

        //
        // Simulate position in London town!
        //
        let location = Coordinate()
        location.lat = 51.50998
        location.lon = -0.1337
        vm.coordinate = location
        
        vm.getCurrentObjects()
        XCTAssertEqual(vm.filteredObjects.value.count, 0)
        XCTAssertEqual(vm.currentObjects.value.count, 2)
        XCTAssertEqual(vm.currentObjects.value.first?.0, "NEARBY - 13")
        XCTAssertEqual(vm.currentObjects.value.first?.1.count, 13)
        XCTAssertEqual(vm.currentObjects.value.last?.0, "RECENTS - 0")

        //
        // Filter the previous search with "Lon" among those 13
        //
        vm.getCurrentObjects("Lon", isFilter: true, isSearch: false)
        XCTAssertEqual(vm.filteredObjects.value.count, 2)
        XCTAssertEqual(vm.filteredObjects.value.first?.0, "NEARBY - 4")
        XCTAssertEqual(vm.filteredObjects.value.first?.1.count, 4)
        XCTAssertEqual(vm.filteredObjects.value.last?.0, "RECENTS - 0")
        if let first = vm.filteredObjects.value.first?.1.first {
            XCTAssertEqual(first.name, "London")
        } else {
            XCTFail("London is not first!")
        }
        
        XCTAssertEqual(vm.currentObjects.value.count, 2)
        XCTAssertEqual(vm.currentObjects.value.first?.0, "NEARBY - 13")
        XCTAssertEqual(vm.currentObjects.value.first?.1.count, 13)
        XCTAssertEqual(vm.currentObjects.value.last?.0, "RECENTS - 0")

        //
        // Simulates the actual search button for "Lon"
        //
        vm.getCurrentObjects("Lon", isFilter: true, isSearch: true)
        
        XCTAssertEqual(vm.filteredObjects.value.count, 1)
        XCTAssertEqual(vm.filteredObjects.value.first?.0, "RESULTS - 425")
        XCTAssertEqual(vm.filteredObjects.value.first?.1.count, 425)
        if let first = vm.filteredObjects.value.first?.1.first {
            XCTAssertEqual(first.name, "London")
        } else {
            XCTFail("London is not first!")
        }
        
        XCTAssertEqual(vm.currentObjects.value.count, 2)
        XCTAssertEqual(vm.currentObjects.value.first?.0, "NEARBY - 13")
        XCTAssertEqual(vm.currentObjects.value.first?.1.count, 13)
        XCTAssertEqual(vm.currentObjects.value.last?.0, "RECENTS - 0")
    }
    
    func testCityViewModelAsynchronously() {
        
        let id = 2643743 // London town!
        let e = expectationWithDescription("Expect return data from server")
        let vm = CityViewModel(cityid: id)
        XCTAssertEqual(vm.city, "")
        XCTAssertEqual(vm.clouds, "")
        XCTAssertEqual(vm.cloudsIcon, "")
        XCTAssertEqual(vm.temperature, "")
        XCTAssertEqual(vm.temperatureMin, "")
        
        XCTAssertEqual(vm.realm.objects(City).filter("id == \(id)").count, 0)
        
        vm.refreshCity {
            XCTAssertEqual(vm.city, "London")
            XCTAssertGreaterThan(vm.clouds.characters.count, 0)
            XCTAssertGreaterThan(vm.cloudsIcon.characters.count, 0)
            XCTAssertGreaterThan(vm.temperature.characters.count, 0)
            XCTAssertGreaterThan(vm.temperatureMin.characters.count, 0)
            
            //
            // London weather has been fetched, parsed and saved persistently!!!
            //
            XCTAssertEqual(vm.realm.objects(City).filter("id == \(id)").count, 1)
            
            //
            // Another call to refresh without the call back means it was retrieved from the local datastore!
            //
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