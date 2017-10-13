//
//  GraphicViewController.swift
//  Calculator
//
//  Created by ZaurNNov on 13.10.2017.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

class GraphicViewController: UIViewController {

    //model test y = f(x)
    var yForX: ((Double) -> Double)? {didSet{updateUI()}}
    
    @IBOutlet weak var graphicView: GraphicView!
    
    func updateUI() {
        graphicView.yForX = yForX
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        yForX = {$0 * cos((1 / $0) * 8)}
    }

}
