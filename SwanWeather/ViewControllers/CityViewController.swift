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
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var viewModel : CityViewModel? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        if let vm = viewModel, d = self.detailDescriptionLabel {
            d.text = vm.temperature
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

