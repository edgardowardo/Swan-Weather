//
//  CityViewController.swift
//  SwanWeather
//
//  Created by EDGARDO AGNO on 05/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import RxSwift

class CityViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var labelCloudy: UILabel!
    @IBOutlet weak var labelTemperatureMin: UILabel!
    @IBOutlet weak var imageCloudy: UIImageView!

    var viewModel : CityViewModel? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        if let vm = viewModel {
            if let t = self.labelCity {
                t.text = vm.city
            }
            if let t = self.labelTemperature {
                t.text = vm.temperature
            }
            if let t = self.labelCloudy {
                t.text = vm.clouds
            }
            if let t = self.labelTemperatureMin {
                t.text = vm.temperatureMin
            }
            if let t = self.imageCloudy {
                t.image = UIImage(named: vm.cloudsIcon)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        guard let viewModel = self.viewModel else { return }
        viewModel.refreshCity()
        viewModel.current
            .asObservable()
            .subscribeNext({ (value) in
                self.configureView()
            })
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

