//
//  ViewController.swift
//  Calculator
//
//  Created by Eric Foster on 11/25/16.
//  Copyright © 2016 Eric Foster. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak private var display: UILabel!
    
    
    @IBOutlet weak private var calculationDisplay: UILabel!
    
    private var numberFormatter = NumberFormatter()
    

    private var firstTouch = true
    
    private var lastTouchADigit = false
    
    private var brain = CalculatorBrain()
    
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display.text!
        
        if firstTouch {
            if digit == "." {
                if textCurrentlyInDisplay.range(of: ".") == nil {
                    display.text = textCurrentlyInDisplay + digit
                    lastTouchADigit = false
                }
                firstTouch = false
            } else {
                display.text = digit
                firstTouch = false
                lastTouchADigit = true
            }
        } else {
            if digit == "." {
                if textCurrentlyInDisplay.range(of: ".") == nil {
                    display.text = textCurrentlyInDisplay + digit
                    lastTouchADigit = false
                }
            } else {
                display.text = textCurrentlyInDisplay + digit
                lastTouchADigit = true
            }
        }
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            numberFormatter.minimumIntegerDigits = 1
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 6
            
            let num = NSNumber(value: newValue)
            
            display.text = numberFormatter.string(from: num)
        }
    }

    private var calculationDisplayValue: String {
        get {
            return calculationDisplay.text!
        }
        set {
            if newValue == " " {
                calculationDisplay.text = ""
            } else {
                if brain.isPartialResult {
                    calculationDisplay.text = String(newValue) + " ..."
                } else {
                    calculationDisplay.text = String(newValue) + " ="
                }
            }
        }
    }
    
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if !firstTouch {
            if let symbol = sender.currentTitle {
                if symbol == "+" || symbol == "-" || symbol == "×" || symbol == "÷" || symbol == "√" {
                    brain.setOperand(displayValue, true)
                } else {
                    brain.setOperand(displayValue, false)
                }
            }
            
            firstTouch = true
        } else {
            brain.veryFirstTouch = true
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol, lastTouchADigit)
        }
        displayValue = brain.result
        calculationDisplayValue = brain.description
        lastTouchADigit = false
    }
    
}

