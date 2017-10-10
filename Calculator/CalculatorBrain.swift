//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by User on 05.10.2017.
//  Copyright © 2017 User. All rights reserved.
//


import Foundation

struct CalculatorBrain {
    
    private var pendingBinaryOperation : PendingBinaryOperation?
    private var cashe: (accumulator: Double?, descriptionAccumulator : String?)
    
    var resultIsPending : Bool  {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    var description : String? {
        get {
            if pendingBinaryOperation == nil {
                return cashe.descriptionAccumulator
            } else {
                return pendingBinaryOperation!.descriptionFunc(
                    pendingBinaryOperation!.descriptionOperand,
                    cashe.descriptionAccumulator ?? "")
            }
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        cashe.accumulator = operand
        if let value = cashe.accumulator {
            cashe.descriptionAccumulator = formatter.string(from: NSNumber(value: value)) ?? ""
        }
    }
    
    var result: Double? {
        get {
            return cashe.accumulator
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, ((String) -> String)?)
        case binaryOperations((Double, Double) -> Double, ((String, String) -> String)?)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt, {"√(" + $0 + ")"}),  // {"√(" + $0 + ")"}
        //"%" : Operation
        "cos" : Operation.unaryOperation(cos, {"cos(" + $0 + ")"}), // {"cos(" + $0 + ")"}
        "sin" : Operation.unaryOperation(sin, {"sin(" + $0 + ")"}),
        "tan" : Operation.unaryOperation(tan, {"tan(" + $0 + ")"}),
        "ln" : Operation.unaryOperation(log, {"ln(" + $0 + ")"}),
        "±" : Operation.unaryOperation({ -$0 }, {"±(" + $0 + ")"}),  // {"±(" + $0 + ")"}
        "×" : Operation.binaryOperations(*, {$0 + " x " + $1}), // {$0 + " x " + $1}
        "÷" : Operation.binaryOperations(/, {$0 + " ÷ " + $1}),
        "+" : Operation.binaryOperations(+, {$0 + " + " + $1}),
        "−" : Operation.binaryOperations(-, {$0 + " - " + $1}), // {$0 + " - " + $1}
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String)
    {
        if let operation = operations[symbol] {
            switch operation {
            
            case .constant(let value):
                cashe.accumulator = value
                cashe.descriptionAccumulator = symbol
                
            case .unaryOperation(let function, var description):
                if cashe.accumulator != nil {
                    cashe.accumulator = function(cashe.accumulator!)
                    if description == nil {
                        description = {symbol + "(" + $0 + ")"}
                    }
                    cashe.descriptionAccumulator = description!(cashe.descriptionAccumulator!)
                }
                
            case .binaryOperations(let function, var description):
                performPendingBinaryOperation()
                if cashe.accumulator != nil  {
                    if description == nil {
                        description = {$0 + " " + symbol + " " + $1}
                    }
                
                    pendingBinaryOperation = PendingBinaryOperation(
                        function: function,
                        firstOperand: cashe.accumulator!,
                        descriptionFunc: description!,
                        descriptionOperand: cashe.descriptionAccumulator!)
                    
                    cashe.accumulator = nil
                    cashe.descriptionAccumulator = nil
                }
                
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && cashe.accumulator != nil {
            cashe.accumulator = pendingBinaryOperation!.perform(with: cashe.accumulator!)
            
            cashe.descriptionAccumulator = pendingBinaryOperation!.performDescription(with: cashe.descriptionAccumulator!)
            
            pendingBinaryOperation = nil
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        var descriptionFunc: (String, String) -> String
        var descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func performDescription(with secondOperand: String) -> String {
            return descriptionFunc(descriptionOperand, secondOperand)
        }
    }
}

let formatter : NumberFormatter = {
    let forrmater = NumberFormatter()
    forrmater.locale = Locale.current
    forrmater.maximumFractionDigits = 6
    forrmater.notANumberSymbol = "Error - not a number symbol!"
    forrmater.numberStyle = .decimal
    forrmater.groupingSeparator = " "

    return forrmater
} ()
