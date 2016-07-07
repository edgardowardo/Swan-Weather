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
        // Filter the previous search with "Lon" among those previous 13
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
    
    func testOpenWeatherMapServiceAsynchronously() {
        
        let id = 2643743 // London town!
        let e = expectationWithDescription("Expect return data from server using the service")

        OpenWeatherMapService.fetchCityAndForecast(withId: id) { (city, forecasts) in
            XCTAssertEqual(city.name, "London")
            if let main = city.main {
                XCTAssertGreaterThan(main.temp, -50)
                XCTAssertLessThan(main.temp, 60)
            } else {
                XCTFail("Expecting temperature data")
            }
            XCTAssertGreaterThan(forecasts.list.count, 0)
            e.fulfill()
        }
        
        waitForExpectationsWithTimeout(60) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
