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
        yForX = {cos(1 / ($0 + 2)) * $0}
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
