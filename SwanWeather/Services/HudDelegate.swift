//
//  HudDelegate.swift
//  SwanWeather
//
//  Created by EDGARDO AGNO on 06/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation

protocol HudDelegate {
    func showHud(text text : String)
    func hideHud()
}