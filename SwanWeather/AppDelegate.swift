//
//  AppDelegate.swift
//  SwanWeather
//
//  Created by EDGARDO AGNO on 05/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import RealmSwift
import MBProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var realm : Realm! = nil

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        if realm == nil {
            realm = try! Realm()
        }
        
        if realm.objects(Spot).count == 0 {
            SpotService.loadCityData()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(methodOfReceivedNotification_willLoadCityData), name: SpotService.Notification.Identifier.willLoadCityData, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(methodOfReceivedNotification_didLoadCityData), name: SpotService.Notification.Identifier.didLoadCityData, object: nil)
        
        return true
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? CityViewController else { return false }
        if topAsDetailController.viewModel == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
    // MARK: - HUD
    
    @objc private func methodOfReceivedNotification_willLoadCityData(notification : NSNotification) {
        self.showHud(text: "Installing spots")
    }
    
    @objc private func methodOfReceivedNotification_didLoadCityData(notification : NSNotification) {
        self.hideHud()
    }
    
    func showHud(text text : String) {
        guard let view = self.window?.rootViewController?.view else { return }
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.dimBackground = true
        hud.labelText = text
    }
    
    func hideHud() {
        guard let view = self.window?.rootViewController?.view else { return }
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
    }
}

