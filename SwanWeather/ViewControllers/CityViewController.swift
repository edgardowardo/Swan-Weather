//
//  CityViewController.swift
//  SwanWeather
//
//  Created by EDGARDO AGNO on 05/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit

class CityViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var viewModel : CityViewModel? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        if let vm = viewModel {
            self.title = vm.city.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

