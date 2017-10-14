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
    {
        didSet {
            let pinchGesture = UIPinchGestureRecognizer(target: graphicView, action: #selector(GraphicView.scale(_:)))
            graphicView.addGestureRecognizer(pinchGesture)
            
            let panGesture = UIPanGestureRecognizer(target: graphicView, action: #selector(GraphicView.originMove(_:)))
            graphicView.addGestureRecognizer(panGesture)
            
            let tapGesture = UITapGestureRecognizer(target: graphicView, action: #selector(GraphicView.origin(_:)))
            tapGesture.numberOfTapsRequired = 2 //double tap
            graphicView.addGestureRecognizer(tapGesture)
            
            graphicView.scale = scale
            graphicView.originSet = originCenter
            
            updateUI()
        }
    }
    
    func updateUI() {
        graphicView.yForX = yForX
    }

    /**
     if first load -> Graph y=sin(x)
    override func viewDidLoad() {
        super .viewDidLoad()
        yForX = {sin($0)}
    }
    */
    
    // MARK: - User folder for saveState variables
    //------
    private let userDefaults = UserDefaults.standard
    
    private struct userDefaultsKeys {
        static let Scale = "GraphicViewController.Scale"
        static let Origin = "GraphicViewController.Origin"
    }
    
    private var factor:[CGFloat] {
        get{
            return (userDefaults.object(forKey: userDefaultsKeys.Origin) as? [CGFloat]) ?? [0.0, 0.0] }
        set {
            userDefaults.set(newValue, forKey: userDefaultsKeys.Origin)}
    }
    
    private var scale: CGFloat {
        get {
            //defaults new, or GraphicView variable value
            return userDefaults.object(forKey: userDefaultsKeys.Scale)
                as? CGFloat ?? 50.0 }
        set {
            userDefaults.set(newValue, forKey: userDefaultsKeys.Scale) }
    }
    
    private var originCenter: CGPoint {
        get {
            //defaults new, or GraphicView variable value
            return CGPoint (x: factor[0] * graphicView.bounds.size.width,
                            y: factor[1] * graphicView.bounds.size.height)
        }
        set {
            factor = [newValue.x / graphicView.bounds.size.width,
                      newValue.y / graphicView.bounds.size.height]
        }
    }
    //------
    
    //if reload app - save state value in local and userDefaults folder
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scale = graphicView.scale
        originCenter = graphicView.originSet
    }
    
    //if center != center afler reload app
    private var oldWidth: CGFloat?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        originCenter = graphicView.originSet
        oldWidth = graphicView.bounds.size.width
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if graphicView.bounds.size.width != oldWidth {
            graphicView.originSet = originCenter
        }
    }
    
    
}
