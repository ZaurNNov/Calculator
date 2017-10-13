//
//  GraphicView.swift
//  Calculator
//
//  Created by ZaurNNov on 13.10.2017.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

class GraphicView: UIView {

    //model test y = f(x)
    var yForX: ((Double) -> Double)? {didSet {setNeedsDisplay()}}
    
    
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
 

}
