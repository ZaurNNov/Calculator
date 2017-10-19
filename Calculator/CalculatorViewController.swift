//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by User on 05.10.2017.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

// ASSIGNMENT III: 2
//Rename the ViewController class = CalculatorViewController
class CalculatorViewController: UIViewController
{
    // ASSIGNMENT I: 4 (Add more color for buttons in UI)
    // ASSIGNMENT II: Extra Credit 2 - app icons
    // ASSIGNMENT II: Extra Credit 3 - add LaunchScreen
    
    //MARK: Actions and Outlets
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    // ASSIGNMENT II: 8
    //display for M -variables
    @IBOutlet weak var displayM: UILabel!
    
    // ASSIGNMENT III: 7
    //variable button (.isEnabled on/off)
    @IBOutlet weak var graphVariableButton: UIButton!
    {
        didSet {
            // ASSIGNMENT III: Extra Credit 1
            graphVariableButton.isEnabled = false
            graphVariableButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton)
    {
        if userIsInTheMiddleOfTyping {
            if let value = displayValue {
              brain.setOperands(value)
            }
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayResult = brain.evaluate(using: variableValues)
    }
    
    @IBAction func touchDigit(_ sender: UIButton)
    {
        let digital = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            // ASSIGNMENT I: 2
            if !textCurrentlyInDisplay.contains(".") || (digital != ".") {
                display.text = textCurrentlyInDisplay + digital
            }
        } else {
            display.text = digital
            userIsInTheMiddleOfTyping = true
        }
    }
    
    // ASSIGNMENT I: 8
    @IBAction func clear(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        brain.clear()
        variableValues = [:] //full clean
        displayResult = brain.evaluate()
    }
    
    // ASSIGNMENT I: Extra Credit 1
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            guard userIsInTheMiddleOfTyping && !display.text!.isEmpty else {return}
            display.text = String(display.text!.characters.dropLast())
            if display.text!.isEmpty {
                userIsInTheMiddleOfTyping = false
                displayResult = brain.evaluate(using: variableValues)
            }
        } else {
            // ASSIGNMENT II: 9
            brain.undo()
            displayResult = brain.evaluate(using: variableValues)
        }
    }
    
    // ASSIGNMENT II: 7
    // →M - button
    @IBAction func setForM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String((sender.currentTitle!).characters.dropFirst())
        
        variableValues[symbol] = displayValue
        displayResult = brain.evaluate(using: variableValues)
    }
    
    // ASSIGNMENT II: 7
    // M - button
    @IBAction func pushM(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        displayResult = brain.evaluate(using: variableValues)
    }
    
    //MARK: Variables
    private var brain = CalculatorBrain() // Model
    
    //for memory current state value from display
    private var variableValues = [String: Double]()
    
    var userIsInTheMiddleOfTyping = false
    
    var displayValue: Double? {
        get {
            if let text = display.text, let value = Double(text){
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = formatter.string(from: NSNumber(value: value))
            }
        }
    }
    
    var displayResult: (result: Double?, isPending: Bool,
        description: String, error: String?) = (nil, false, " ", nil) {
        
        // odserver, modifing 3 IBOutlet labels
        didSet {
            //block for variable button
            graphVariableButton.isEnabled = !displayResult.isPending
            graphVariableButton.backgroundColor = displayResult.isPending ? UIColor.lightGray : UIColor.white
            
            switch displayResult {
            case (nil, _, " ", nil) : displayValue = 0
            case (let result, _, _, nil): displayValue = result
            case (_, _, _, let error): display.text = error!
            }
            
            descriptionDisplay.text = displayResult.description != " " ?
                displayResult.description + (displayResult.isPending ? " …" : " =") : " "
            displayM.text = formatter.string(from: NSNumber(value:variableValues["M"] ?? 0))
        }
    }
    
    // Segue for "Graphic build" button
    //------
    private struct segueIdentifiles
    {
        static let GraphButtonSegue = "GraphButtonSegue"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        
        if let navigationController = destination as? UINavigationController {
            destination = navigationController.visibleViewController
                ?? destination
        }
        
        if let id = segue.identifier,
            id == segueIdentifiles.GraphButtonSegue,
            let vc = destination as? GraphicViewController {
                prepareGraphicViewController(vc)
        }
    }
    
    // ASSIGNMENT III: 9
    private func prepareGraphicViewController(_ vc: GraphicViewController) {
        vc.yForX = {
            [weak weakSelf = self] x in
            //set x - value (for y=f(x) in graphic)
            weakSelf?.variableValues["M"] = x
            return weakSelf?.brain.evaluate(using: weakSelf?.variableValues).result
        }
        // ASSIGNMENT III: 9 - set Graph title as func f(x)
        vc.navigationItem.title = "y = " + brain.evaluate(using: variableValues).description
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == segueIdentifiles.GraphButtonSegue {
            let result = brain.evaluate()
            return !result.isPending
        }
        return false
    }
    
    // MARK: - User folder for saveState variables
    //------
    private let userDefaults = UserDefaults.standard
    private struct userDefaultsKey {
        static let Programm = "CalculatorViewController.Programm"
    }
    
    // someDataObject type
    typealias PropertyList = AnyObject
    
    // get & set for someDataObject from userDefaults folder
    private var programm: PropertyList? {
        get {
            return userDefaults.object(forKey: userDefaultsKey.Programm) as PropertyList?
        }
        set {
            userDefaults.set(newValue, forKey: userDefaultsKey.Programm)
        }
    }
    
    //if reload app - save state value in local and userDefaults folder
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let saveProgramm = programm as? [Any] {
            brain.programm = saveProgramm as PropertyList
            displayResult = brain.evaluate(using: variableValues)
            
            if let gVC = splitViewController?.viewControllers.last?.contetViewController as? GraphicViewController {
                prepareGraphicViewController(gVC)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !brain.evaluate(using: variableValues).isPending {
            programm = brain.programm
        }
    }
    
}

//if viewController as navigationController
extension UIViewController {
    var contetViewController: UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController
                ?? self
        } else {
            return self
        }
    }
}

extension CalculatorViewController: UISplitViewControllerDelegate
{
    override func awakeFromNib() {
        super.awakeFromNib()
        self.splitViewController?.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    }
}
