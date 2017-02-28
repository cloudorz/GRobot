//
//  ViewController.swift
//  GRobot
//
//  Created by Cloud Dai on 27/2/2017.
//  Copyright © 2017 Cloud Dai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func viewDidAppear(_ animated: Bool)
  {
    super.viewDidAppear(animated)

    let manager = RobotManager()
    manager.run()
    print("The best robot: \(manager.theBestRobot)")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

