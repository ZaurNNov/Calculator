//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by User on 05.10.2017.
//  Copyright © 2017 User. All rights reserved.
//


import Foundation

struct CalculatorBrain {
    
    //MARK: Struct for history operations
    
    private enum OperationsEnumerating {
        case operand(Double)
        case operation(String)
        case variable(String)
    }
    
    private var historyProgram = [OperationsEnumerating]()
    
    mutating func setOperand(_ operand: Double) {
        historyProgram.append(
            OperationsEnumerating.operand(operand))
    }

    mutating func setOperand(_ opetation: String) {
        historyProgram.append(
            OperationsEnumerating.operation(opetation))
    }

    mutating func setOperand(variable name: String) {
        historyProgram.append(OperationsEnumerating.variable(name))
    }
    
    //MARK: Variables
    
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
                return pendingBinaryOperation!.descriptionFunction(
                    pendingBinaryOperation!.descriptionOperand,
                    cashe.descriptionAccumulator ?? "")
            }
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
        case nullOperation (() -> Double, String)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt, {"√(" + $0 + ")"}),
        "%" : Operation.binaryOperations({($0 / $1) * 100}, {$0 + " % " + $1}),
        "cos" : Operation.unaryOperation(cos, {"cos(" + $0 + ")"}), // {"cos(" + $0 + ")"}
        "sin" : Operation.unaryOperation(sin, {"sin(" + $0 + ")"}),
        "tan" : Operation.unaryOperation(tan, {"tan(" + $0 + ")"}),
        "ln" : Operation.unaryOperation(log, {"ln(" + $0 + ")"}),
        "±" : Operation.unaryOperation({ -$0 }, {"±(" + $0 + ")"}),  // {"±(" + $0 + ")"})
        "×" : Operation.binaryOperations(*, {"(" + $0 + ")x" + $1}), // {"(" + $0 + ")x" + $1}
        "÷" : Operation.binaryOperations(/, {$0 + " ÷ " + $1}),
        "+" : Operation.binaryOperations(+, {$0 + " + " + $1}),
        "−" : Operation.binaryOperations(-, {$0 + " - " + $1}), // {$0 + " - " + $1}
        "=" : Operation.equals,
        "Rand" : Operation.nullOperation({Double(arc4random())/Double(UInt32.max)}, "Rand()")
    ]
    
    //MARK: Mutating Functions
    
    // clear all
    mutating func clear() {
        cashe.accumulator = nil
        pendingBinaryOperation = nil
        cashe.descriptionAccumulator = " "
    }
    
    mutating func setOperands(_ operand: Double) {
        cashe.accumulator = operand
        if let value = cashe.accumulator {
            cashe.descriptionAccumulator = formatter.string(from: NSNumber(value: value)) ?? ""
        }
    }

    mutating func performOperation(_ symbol: String)
    {
        if let operation = operations[symbol] {
            switch operation {
            
            case .nullOperation(let function, let descriptionFunction):
                cashe.accumulator = function()
                cashe.descriptionAccumulator = descriptionFunction
                
            case .constant(let value):
                cashe.accumulator = value
                cashe.descriptionAccumulator = symbol
                
            case .unaryOperation(let function, var descriptionFunction):
                if cashe.accumulator != nil {
                    cashe.accumulator = function(cashe.accumulator!)
                    if description == nil {
                        descriptionFunction = {symbol + "(" + $0 + ")"}
                    }
                    cashe.descriptionAccumulator = descriptionFunction!(cashe.descriptionAccumulator!)
                }
                
            case .binaryOperations(let function, var descriptionFunction):
                performPendingBinaryOperation()
                if cashe.accumulator != nil  {
                    if description == nil {
                        descriptionFunction = {$0 + " " + symbol + " " + $1}
                    }
                
                    pendingBinaryOperation = PendingBinaryOperation(
                        function: function,
                        firstOperand: cashe.accumulator!,
                        descriptionFunction: descriptionFunction!,
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
        
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func performDescription(with secondOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondOperand)
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
