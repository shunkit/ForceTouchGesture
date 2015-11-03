//
//  ViewController.swift
//  ForceTouchGestureExample
//
//  Created by Shunki Tan on 2015/10/31.
//  Copyright © 2015年 Shunki Tan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var touchView: UIView!
    @IBOutlet private weak var currentTouchForceLabel: UILabel!
    @IBOutlet private weak var minimumTouchForceLabel: UILabel!
    @IBOutlet private weak var minimumTouchForceSlider: UISlider!
    
    private var forceTouchGestureRecognizer: ForceTouchGestureRecognizer!
    
    enum ForceState {
        
        case NoTouch
        case Safe
        case Warning
        case Danger
        
        static func getState(current current: CGFloat, max: CGFloat) -> ForceState {
            
            switch (current / max) {
            case 0:
                return .NoTouch
            case 0..<0.33:
                return .Safe
            case 0.33..<0.66:
                return .Warning
            default:
                return .Danger
            }
        }
        
        var color: UIColor {
            
            switch self {
            case .NoTouch:
                return UIColor(white: 0.05, alpha: 1.0)
            case .Safe:
                return UIColor(red:0.49, green:0.95, blue:0.37, alpha:1)
            case .Warning:
                return UIColor(red:0.97, green:0.9, blue:0.46, alpha:1)
            case .Danger:
                return UIColor(red:0.92, green:0.35, blue:0.31, alpha:1)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = ForceTouchGestureRecognizer(target: self, action: "forceTouchHandler:")
        gestureRecognizer.minimumForce = CGFloat(self.minimumTouchForceSlider.value)
        gestureRecognizer.vibrationEnabled = true
        self.touchView.addGestureRecognizer(gestureRecognizer)
        self.forceTouchGestureRecognizer = gestureRecognizer
        
        self.currentTouchForceLabel.text = String(format: "%0.2f", 0)
        self.currentTouchForceLabel.textColor = ForceState.NoTouch.color
    }
    
    func forceTouchHandler(gestureRecognizer: ForceTouchGestureRecognizer) {
        
        let force = gestureRecognizer.force
        
        switch gestureRecognizer.state {
        case .Ended:
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                self.touchView.backgroundColor = ForceState.Danger.color
                }, completion: { (_) -> Void in
                
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        
                        self.touchView.backgroundColor = UIColor.whiteColor()
                        self.updateCurrentTouchForce(0)
                    })
            })
        case .Changed:
            self.updateCurrentTouchForce(force)
            
        case .Cancelled, .Failed:
            self.updateCurrentTouchForce(0)
            
        default:
            break
        }
    }
    
    private func updateCurrentTouchForce(force: CGFloat) {
        
        self.currentTouchForceLabel.text = String(format: "%0.2f", force)
        self.currentTouchForceLabel.textColor = ForceState.getState(current: force, max: CGFloat(self.minimumTouchForceSlider.value)).color
    }
    
    @IBAction func minimumTouchForceValueChanged(sender: UISlider) {
        
        self.minimumTouchForceLabel.text = String(format: "%0.2f", sender.value)
        self.forceTouchGestureRecognizer.minimumForce = CGFloat(sender.value)
    }
}

