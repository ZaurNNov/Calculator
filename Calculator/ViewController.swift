//
//  ViewController.swift
//  Calculator
//
//  Created by User on 05.10.2017.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    //MARK: Actions and Outlets
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            if let value = displayValue {
              brain.setOperands(value)
            }
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        displayValue = brain.result
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        
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
        brain.clear()
        descriptionDisplay.text = " "
        displayValue = 0
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping && !display.text!.isEmpty else {return}
        
        display.text = String(display.text!.characters.dropLast())
        if display.text!.isEmpty {
            displayValue = 0
        }
    }
    
    @IBAction func setForM(_ sender: UIButton) {
    }
    
    @IBAction func pushM(_ sender: UIButton) {
    }
    
    //MARK: Variables
    private var brain = CalculatorBrain()
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
            descriptionDisplay.text = brain.description! + (brain.resultIsPending ? " ..." : " =")
        }
    }

}

