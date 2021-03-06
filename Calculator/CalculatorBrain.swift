//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by User on 05.10.2017.
//  Copyright © 2017 User. All rights reserved.
//


import Foundation

struct CalculatorBrain {
    
    private enum OperationsEnumerating {
        case operand(Double)
        case operation(String)
        case variable(String)
    }
    
    private var historyProgram = [OperationsEnumerating]()
    
    mutating func setOperands(_ operand: Double) {
        historyProgram.append(OperationsEnumerating.operand(operand))
    }
    
    mutating func setOperand(variable name: String) {
        historyProgram.append(OperationsEnumerating.variable(name))
    }
    
    mutating func performOperation(_ symbol: String) {
        historyProgram.append(OperationsEnumerating.operation(symbol))
    }
    
    // clear all
    mutating func clear() {
        historyProgram.removeAll()
    }
    
    //undo
    mutating func undo() {
        if !historyProgram.isEmpty {
            historyProgram = Array(historyProgram.dropLast())
        }
    }
    
    private enum Operation {
        case constant(Double)
        // ASSIGNMENT II: Extra Credit 1
        //function that detects an error ((String) -> String)? and ((Double) -> String?)?
        
        case unaryOperation (
            (Double) -> Double,
            ((String) -> String)?,
            ((Double) -> String?)?)
        
        case binaryOperations (
            (Double, Double) -> Double,
            ((String, String) -> String)?,
            ((Double, Double) -> String?)?, Int)
        
        case equals
        case nullOperation (() -> Double, String)
    }
    
    // ASSIGNMENT I: 3 (Add more buttons in UI)
    private var operations: Dictionary<String,Operation> = [
        // ASSIGNMENT I: 7
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        // ASSIGNMENT II: Extra Credit 1 (error string)
        "√" : Operation.unaryOperation(sqrt, nil, { $0 < 0 ? "√ отрицательного числа" : nil }),
        "%" : Operation.binaryOperations({($0 / $1) * 100}, nil, nil, 1), //{$0 + " % " + $1}
        "cos" : Operation.unaryOperation(cos, nil, nil), // {"cos(" + $0 + ")"})
        "sin" : Operation.unaryOperation(sin, nil, nil), // {"sin(" + $0 + ")"}),
        "tan" : Operation.unaryOperation(tan, nil, nil), // {"tan(" + $0 + ")"}),
        "ln" : Operation.unaryOperation(log, nil, nil),  // {"ln(" + $0 + ")"}),
        "±" : Operation.unaryOperation({ -$0 }, nil, nil),  // {"±(" + $0 + ")"}),
        "×" : Operation.binaryOperations(*, {"(" + $0 + ") x " + $1}, nil, 1), // {"(" + $0 + ")x" + $1})
        // ASSIGNMENT II: Extra Credit 1 (error string)
        "÷" : Operation.binaryOperations(/, nil, { $1 == 0.0 ? "Деление на нуль" : nil }, 1),
        "+" : Operation.binaryOperations(+, nil, nil, 0), // {$0 + " + " + $1}),
        "−" : Operation.binaryOperations(-, nil, nil, 0), // {$0 + " - " + $1}), // {$0 + " - " + $1}
        "=" : Operation.equals,
        // ASSIGNMENT I: Extra Credit 3
        //"Rand" : Operation.nullOperation({Double(arc4random())/Double(UInt32.max)}, "Rand()")
    ]
    
    struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        
        var validator: ((Double, Double) -> String?)?
        var prevPrecedence: Int
        var precedence: Int
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func performDescription(with secondOperand: String) -> String {
            var descriptionNewOperand = descriptionOperand
            
            if prevPrecedence < precedence {
                descriptionNewOperand = "(" + descriptionNewOperand + ")"
            }
            return descriptionFunction(descriptionNewOperand, secondOperand)
        }
        
        func validate (with secondOperand: Double) -> String? {
            guard let validator = validator else {return nil}
            return validator(firstOperand, secondOperand)
        }
    }
    
    // MARK: Property list
    // for save state in userDefaults folde(from CalculatorViewController)
    // someDataObject type
    typealias PropertyList = AnyObject
    
    // get & set for someDataObject from userDefaults folder
    var programm: PropertyList {
        get {
            var propertyListProgramm = [Any]()
            for operationsList in historyProgram {
                //substituting the value for the "Any" value
                switch operationsList {
                case .operand(let operand):
                    propertyListProgramm.append(operand as Any)
                case .operation(let symbol):
                    propertyListProgramm.append(symbol as Any)
                case .variable(let named):
                    propertyListProgramm.append(named as Any)
                }
            }
            return propertyListProgramm as PropertyList
        }
        set {
            clear()
            if let arrayOfAny = newValue as? [Any] {
                for operationsList in arrayOfAny {
                    //inverse value from "Any" to specified type value
                    if let operand = operationsList as? Double {
                        historyProgram.append(
                            OperationsEnumerating.operand(operand))
                    } else if let symbol = operationsList as? String {
                        if operations[symbol] != nil {
                            // symbol - operation
                            historyProgram.append(
                                OperationsEnumerating.operation(symbol))
                        } else {
                            // symbol - variable
                            historyProgram.append(
                                OperationsEnumerating.variable(symbol))
                        }
                    }
                }
            }
        }
    }
    
    // ASSIGNMENT II: 2
    // MARK: - evaluate (new struct)
    //--------------------------------------------
    
    // ASSIGNMENT II: 4
    func evaluate(using variables: Dictionary<String,Double>? = nil) ->
        (result: Double?, isPending: Bool, description: String, error: String?){
            
            // MARK: - Local variables evaluate
            var pendingBinaryOperation : PendingBinaryOperation?
            var cashe: (accumulator: Double?, descriptionAccumulator : String?)
            var error: String?
            var prevPrecedence = Int.max
            
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
            
            var resultIsPending : Bool  {
                get {
                    return pendingBinaryOperation != nil
                }
            }
            
            // MARK: - Local functions in evaluate
            func setOperand(_ operand: Double) {
                cashe.accumulator = operand
                if let value = cashe.accumulator {
                    cashe.descriptionAccumulator = formatter.string(from: NSNumber(value: value)) ?? ""
                    prevPrecedence = Int.max
                }
            }
            
            func setOperand (variable named: String) {
                cashe.accumulator = variables?[named] ?? 0
                cashe.descriptionAccumulator = named
                prevPrecedence = Int.max
            }
            
            // ASSIGNMENT II: 3
            func performOperation(_ symbol: String)
            {
                if let operation = operations[symbol] {
                    error = nil
                    
                    switch operation {
                    case .nullOperation(let function, let descriptionFunction):
                        cashe = (function(),descriptionFunction)
                    
                    case .constant(let value): cashe = (value, symbol)
                    
                    case .unaryOperation(let function, var descriptionFunction, let validator):
                        if cashe.accumulator != nil {
                            error = validator?(cashe.accumulator!)
                            cashe.accumulator = function(cashe.accumulator!)
                            
                            if descriptionFunction == nil {
                                descriptionFunction = {symbol + "(" + $0 + ")"}
                            }
                            
                            cashe.descriptionAccumulator = descriptionFunction!(cashe.descriptionAccumulator!)
                        }
                    
                    case .binaryOperations(let function, var descriptionFunction, let validator, let precedence):
                        performPendingBinaryOperation()
                        
                        if cashe.accumulator != nil  {
                            if descriptionFunction == nil {
                                descriptionFunction = {$0 + " " + symbol + " " + $1}
                            }
                            
                            pendingBinaryOperation = PendingBinaryOperation(
                                function: function,
                                firstOperand: cashe.accumulator!,
                                descriptionFunction: descriptionFunction!,
                                descriptionOperand: cashe.descriptionAccumulator!,
                                validator: validator,
                                prevPrecedence: prevPrecedence,
                                precedence: precedence)
                            
                            cashe = (nil, nil)
                        }
                    case .equals:
                        performPendingBinaryOperation()
                    }
                }
            }
            
            func performPendingBinaryOperation() {
                if pendingBinaryOperation != nil && cashe.accumulator != nil {
                    //проверка на ошибку
                    error = pendingBinaryOperation!.validate(with: cashe.accumulator!)
                    
                    cashe.accumulator =
                        pendingBinaryOperation!.perform(with: cashe.accumulator!)
                    
                    cashe.descriptionAccumulator =
                        pendingBinaryOperation!.performDescription(with: cashe.descriptionAccumulator!)
                    
                    prevPrecedence = pendingBinaryOperation!.precedence
                    
                    pendingBinaryOperation = nil
                }
            }
            
            // MARK: - Body evaluate
            //----------------------------------
            guard !historyProgram.isEmpty else {
                return (nil, false, " ", nil)
            }
            
            prevPrecedence = Int.max
            pendingBinaryOperation = nil
            
            for operations in historyProgram {
                switch operations {
                case .operand(let operand): setOperand(operand)
                case .operation(let operation): performOperation(operation)
                case .variable(let variable): setOperand(variable: variable)
                }
            }
            
            return (result, resultIsPending, description ?? " ", error)
            //----------------------------------
            //---END - evaluate fuctions
    }
    
    // ASSIGNMENT II: 5
    //MARK: Not more need (@available) in struct CalculatorBrain
    
    @available(iOS, deprecated, message: "No longer needed")
    var result: Double? {
        get {
            return evaluate().result
        }
    }
    
    // ASSIGNMENT I: 5
    @available(iOS, deprecated, message: "No longer needed")
    var resultIsPending: Bool {
        get {
            return evaluate().isPending
        }
    }
    
    // ASSIGNMENT I: 6
    @available(iOS, deprecated, message: "No longer needed")
    var description: String {
        get {
            return evaluate().description
        }
    }
}

// ASSIGNMENT I: Extra Credit 2
let formatter : NumberFormatter = {
    let forrmater = NumberFormatter()
    forrmater.locale = Locale.current
    forrmater.maximumFractionDigits = 6
    forrmater.notANumberSymbol = "Error - not a number symbol!"
    forrmater.numberStyle = .decimal
    forrmater.groupingSeparator = " "
    
    return forrmater
} ()
