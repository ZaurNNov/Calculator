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
    var scale: CGFloat = 50.0  {didSet {setNeedsDisplay()}}
    var lineWidth: CGFloat = 2.0 {didSet {setNeedsDisplay()}}
    var color: UIColor = UIColor.cyan {didSet {setNeedsDisplay()}}
    var colorAxes: UIColor = UIColor.brown {didSet {setNeedsDisplay()}}
    
    //dot in center
    var originSet: CGPoint? {didSet {setNeedsDisplay()}}
    
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
        drawCurveInRect(bounds, origin: origin, scale: scale)
    }
    
    func drawCurveInRect(_ bounds: CGRect, origin: CGPoint, scale: CGFloat) {
        //parametic for line
        var xGraph, yGraph : CGFloat
        var x, y : Double
        var isFirstPoint = true
        
        //graphing discontinuous points
        var oldYGraph: CGFloat = 0.0
        var disContinue: Bool {
            return abs(yGraph - oldYGraph) > max(bounds.width, bounds.height) * 1.5
        }
        
        if yForX != nil {
            color.set()
            let path = UIBezierPath()
            path.lineWidth = lineWidth
            
            for i in 0...Int(bounds.size.width * contentScaleFactor) {
                
                xGraph = CGFloat(i) / contentScaleFactor
                x = Double((xGraph - origin.x) / scale)
                y = (yForX)!(x) //fuction line y = f(x)
                
                guard y.isFinite else {continue}
                yGraph = origin.y - CGFloat(y) * scale
                
                if isFirstPoint {
                    path.move(to: CGPoint(x: xGraph, y: yGraph))
                    isFirstPoint = false
                } else {
                    if disContinue {
                        isFirstPoint = true
                    }
                    path.addLine(to: CGPoint(x: xGraph, y: yGraph))
                }
            }
            path.stroke()
        }
    }
    
    
 

}
