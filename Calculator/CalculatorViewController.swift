//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by User on 05.10.2017.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController
{
    //MARK: Actions and Outlets
    @IBOutlet weak var display: UILabel!
    //history:
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    //display for M -variables
    @IBOutlet weak var displayM: UILabel!
    
    //variable button (.isEnabled on/off)
    @IBOutlet weak var graphVariableButton: UIButton!
    {
        didSet {
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
            if !textCurrentlyInDisplay.contains(".") || (digital != ".") {
                display.text = textCurrentlyInDisplay + digital
            }
        } else {
            display.text = digital
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        brain.clear()
        variableValues = [:] //full clean
        displayResult = brain.evaluate()
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            guard userIsInTheMiddleOfTyping && !display.text!.isEmpty else {return}
            display.text = String(display.text!.characters.dropLast())
            if display.text!.isEmpty {
                userIsInTheMiddleOfTyping = false
                displayResult = brain.evaluate(using: variableValues)
            }
        } else {
            brain.undo()
            displayResult = brain.evaluate(using: variableValues)
        }
    }
    
    // →M - button
    @IBAction func setForM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String((sender.currentTitle!).characters.dropFirst())
        
        variableValues[symbol] = displayValue
        displayResult = brain.evaluate(using: variableValues)
    }
    
    // M - button
    @IBAction func pushM(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        displayResult = brain.evaluate(using: variableValues)
    }
    
    //MARK: Variables
    private var brain = CalculatorBrain()
    
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
        
        // Наблюдатель Свойства модифицирует три IBOutlet метки
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
    
    private struct segueIdentifiles
    {
        static let GraphButtonSegue = "GraphButtonSegue"
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        
        if let navigationController = destination as? UINavigationController {
            destination = navigationController.visibleViewController ?? destination
        }
        
        if let id = segue.identifier ,
            id == segueIdentifiles.GraphButtonSegue ,
            let vc = destination as? GraphicViewController {
                prepareGraphicViewController(vc)
        }
    }
    
    func prepareGraphicViewController(_ vc: GraphicViewController) {
        vc.yForX = {
            [weak weakSelf = self] x in
            weakSelf?.variableValues["M"] = x
            return (weakSelf?.brain.evaluate(using: weakSelf?.variableValues).result)!
        }
        vc.navigationItem.title = "y = " + brain.evaluate(using: variableValues).description
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == segueIdentifiles.GraphButtonSegue {
            let result = brain.evaluate()
            return result.isPending
        }
        return false
    }
    

    
}

//if viewController as navigationController
extension UIViewController {
    var contetViewController: UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController ?? self
        } else {
            return self
        }
    }
}

