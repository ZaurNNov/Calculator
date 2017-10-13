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
    
    //parameters for graph
    var scale: CGFloat = 50.0
    var lineWidth: CGFloat = 2.0
    var color: UIColor = UIColor.cyan
    var colorAxes: UIColor = UIColor.brown
    
    //dot in center
    var originSet: CGPoint?
    
    //dot in center init
    private var origin: CGPoint
    {
        get {return originSet ?? CGPoint(x: self.bounds.midX, y: self.bounds.midY)}
        set {originSet = newValue}
    }
    
    private var axesDrawer = AxesDrawer()
    
    override func draw(_ rect: CGRect) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.color = colorAxes
        axesDrawer.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
    }
    
    
    
 

}
