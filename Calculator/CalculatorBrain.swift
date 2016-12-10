//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Eric Foster on 11/30/16.
//  Copyright © 2016 Eric Foster. All rights reserved.
//

import Foundation



class CalculatorBrain {
    
    private var accumulator = 0.0
    
    private var lastOperand = ""
    
    private var numberFormatter = NumberFormatter()
    
    private var numString: String! = ""
    
    private var isUnaryOperation = false
    
    private var noBinaryOperation = true
    
    private var lastTouchABinaryOperationSymbol = false
    
    private var putOperandInParenthesis = false
    
    internal var veryFirstTouch = false
    
    internal var description: String = ""
        
    internal func setOperand(_ operand: Double, _ binaryOperation: Bool) {
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 6
        
        let number = NSNumber(value: operand)
        let operandString = numberFormatter.string(from: number)
        
        numString = numberFormatter.string(from: number)
        
        accumulator = operand
        lastOperand = operandString!
        
        if binaryOperation {
            print("Binary")
            adjustOperationDescription(nil, numString)
        }
    }
    
    private var operations: Dictionary<String,Operation> = [
        "c": Operation.Reset(0.0),
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "√": Operation.UnaryOperation(sqrt),
        "sin": Operation.UnaryOperation(sin),
        "cos": Operation.UnaryOperation(cos),
        "±": Operation.UnaryOperation({ $0 * -1 }),
        "%": Operation.UnaryOperation({ $0 * 0.01 }),
        "×": Operation.BinaryOperation({ $0 * $1 }),
        "÷": Operation.BinaryOperation({ $0 / $1 }),
        "+": Operation.BinaryOperation({ $0 + $1 }),
        "−": Operation.BinaryOperation({ $0 - $1 }),
        "=": Operation.Equals
    ]
    
    private enum Operation {
        case Reset(Double)
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private var pendingUnary: PendingUnaryOperationsInfo?
    
    private var pendingBinary: PendingBinaryOperationsInfo?
    
    internal var isPartialResult: Bool {
        get {
            if pendingBinary == nil || pendingUnary == nil {
                return false
            } else {
                return true
            }
        }
    }
    
    private struct PendingUnaryOperationsInfo {
        var unaryFunction: (Double) -> Double
        var operand: Double
    }
    
    private struct PendingBinaryOperationsInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    internal func performOperation(_ mathSymbol: String, _ lastTouch: Bool) {
        
        if let operation = operations[mathSymbol] {
            switch operation {
            case .Reset(let value):
                //Reset Calculator to initial settings..
                accumulator = value
                description = " "
                pendingUnary = nil
                pendingBinary = nil
                lastTouchABinaryOperationSymbol = false
                noBinaryOperation = true
            case .Constant(let value):
                lastTouchABinaryOperationSymbol = false
                
                accumulator = value
                //Pass math operation symbol to description function...
                adjustOperationDescription(mathSymbol, nil)
                isUnaryOperation = false
            case .UnaryOperation(let function):
                lastTouchABinaryOperationSymbol = false
                
                accumulator = function(accumulator)
                pendingUnary = PendingUnaryOperationsInfo(unaryFunction: function, operand: accumulator)
                isUnaryOperation = true
                //Pass math operation symbol to description function...
                adjustOperationDescription(mathSymbol, nil)
            case .BinaryOperation(let function):
                noBinaryOperation = false
                if lastTouch {
                    executePendingOperation()
                }
                pendingBinary = PendingBinaryOperationsInfo(binaryFunction: function, firstOperand: accumulator)
                
                isUnaryOperation = false
                //Pass math operation symbol to description function...
                adjustOperationDescription(mathSymbol, nil)
            case .Equals:
                lastTouchABinaryOperationSymbol = false
                
                if lastTouch || isUnaryOperation {
                    executePendingOperation()
                    isUnaryOperation = false
                }
                adjustOperationDescription(mathSymbol, numString)
            }
        }
    }
    
    
    private func adjustOperationDescription(_ symbol: String?, _ number: String?) {
        if number == nil {
            if symbol != "=" {
                if isUnaryOperation {
                    if veryFirstTouch {
                        description += symbol!
                        putOperandInParenthesis = true
                        veryFirstTouch = false
                    } else {
                        if isPartialResult {
                            let range = description.index(description.endIndex, offsetBy: -(Int(lastOperand.characters.count)))..<description.endIndex
                            description.removeSubrange(range)
                            
                            description = description + symbol! + "(\(lastOperand))"
                        } else {
                            description = symbol! + "(\(description))"
                        }
                    }
                } else {
                    if !lastTouchABinaryOperationSymbol {
                        description += " \(symbol!) "
                        lastTouchABinaryOperationSymbol = true
                    }
                }
            } else {
                description += "(\(number!))"
                putOperandInParenthesis = false
            }
        } else {
            description += number!
        }
    }
    
    
    private func executePendingOperation() {
        if pendingBinary != nil {
            accumulator = pendingBinary!.binaryFunction(pendingBinary!.firstOperand, accumulator)
            pendingBinary = nil
            pendingUnary = nil
        } else if pendingUnary != nil {
            accumulator = pendingUnary!.unaryFunction(accumulator)
            pendingUnary = nil
            pendingBinary = nil
        }
    }
    
    internal var result: Double {
        get {
            return accumulator
        }
    }
}
