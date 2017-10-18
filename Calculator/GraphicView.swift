//
//  GraphicView.swift
//  Calculator
//
//  Created by ZaurNNov on 13.10.2017.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

@IBDesignable
class GraphicView: UIView {

    //model test y = f(x)
    var yForX: ((Double) -> Double?)? {didSet {setNeedsDisplay()}}
    
    //parameters for graph
    @IBInspectable
    var scale: CGFloat = 50.0 {didSet {setNeedsDisplay()}}
    @IBInspectable
    var lineWidth: CGFloat = 2.0 {didSet {setNeedsDisplay()}}
    @IBInspectable
    var color: UIColor = UIColor.cyan {didSet {setNeedsDisplay()}}
    @IBInspectable
    var colorAxes: UIColor = UIColor.brown {didSet {setNeedsDisplay()}}
    
    //dot in center
    var originSet = CGPoint.zero {didSet {setNeedsDisplay()}}
    
    private var graphCenter: CGPoint {
        return convert(center, from: superview)
    }
    
    //dot in center init
    private var origin: CGPoint
    {
        get {
            var origin = originSet
            origin.x += graphCenter.x
            origin.y += graphCenter.y
            return origin
        }
        set {
            var origin = newValue
            origin.x -= graphCenter.x
            origin.y -= graphCenter.y
            originSet = origin
        }
    }
    
    private var axesDrawer = AxesDrawer()
    
    override func draw(_ rect: CGRect) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.color = colorAxes
        axesDrawer.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
        drawCurveInRect(bounds, origin: origin, scale: scale)
    }
    
    func drawCurveInRect(_ bounds: CGRect, origin: CGPoint, scale: CGFloat)
    {
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
            
            for i in 0...Int(bounds.size.width * contentScaleFactor)
            {
                xGraph = CGFloat(i) / contentScaleFactor
                x = Double((xGraph - origin.x) / scale)
                
                guard let y = (yForX)!(x),
                    y.isFinite else {continue}
                
                yGraph = origin.y - CGFloat(y) * scale
                
                if isFirstPoint {
                    path.move(to: CGPoint(x: xGraph, y: yGraph))
                    isFirstPoint = false
                } else {
                    if disContinue {
                        isFirstPoint = true
                    } else {
                       path.addLine(to: CGPoint(x: xGraph, y: yGraph))
                    }
                }
            }
            path.stroke()
        }
    }
    
    private var snapshot: UIView?
    //Pinch func (scale + snapshot)
    @objc
    func scale(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            snapshot = self.snapshotView(afterScreenUpdates: false)
            snapshot!.alpha = 0.8
            self.addSubview(snapshot!)
            
        case .changed:
            let touch = CGPoint(
                x:graphCenter.x + originSet.x,
                y:graphCenter.y + originSet.y)
            
            snapshot!.frame.size.height *= gesture.scale
            snapshot!.frame.size.width *= gesture.scale
            snapshot!.frame.origin.x = snapshot!.frame.origin.x * gesture.scale +
                (1 - gesture.scale) * touch.x
            snapshot!.frame.origin.y = snapshot!.frame.origin.y * gesture.scale +
                (1 - gesture.scale) * touch.y
            gesture.scale = 1.0
            
        case .ended:
            let changedScale = snapshot!.frame.height / self.frame.height
            scale *= changedScale
            
            snapshot!.removeFromSuperview()
            snapshot = nil
            setNeedsDisplay()
            
        default: break
        }
    }
    
    //PanGesture func (moove graph + snapshot)
    @objc
    func originMove(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            snapshot = self.snapshotView(afterScreenUpdates: false)
            snapshot!.alpha = 0.6
            self.addSubview(snapshot!)
            
        case .changed:
            let translation = gesture.translation(in: self)
            if translation != CGPoint.zero {
                snapshot!.center.x += translation.x
                snapshot!.center.y += translation.y
                
                gesture.setTranslation(CGPoint.zero, in: self)
            }
            
        case .ended:
            origin.x += snapshot!.frame.origin.x
            origin.y += snapshot!.frame.origin.y
            
            snapshot!.removeFromSuperview()
            snapshot = nil
            setNeedsDisplay()
            
        default: break
        }
    }
    
    //TapGesture
    @objc
    func origin(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            origin = gesture.location(in: self)
        }
    }

}
