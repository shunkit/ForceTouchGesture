//
//  ForceTouchGestureRecognizer.swift
//  ForceTouchGesture
//
//  Created by Shunki Tan on 2015/11/03.
//  Copyright © 2015年 Shunki Tan. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass
import AudioToolbox

public class ForceTouchGestureRecognizer: UIGestureRecognizer {
    
    public private(set) var force: CGFloat = 0
    public private(set) var forceTouchAvailable = false
    public var minimumForce: CGFloat = 3.0
    public var vibrationEnabled = false
    
    private let capabilityMonitor = ForceTouchCapabilityMonitor()
    
    override init(target: AnyObject?, action: Selector) {
        
        super.init(target: target, action: action)
        
        self.forceTouchAvailable = self.capabilityMonitor.available
        self.capabilityMonitor.didChange = { [weak self] (forceTouchAvailable) in
            
            self?.forceTouchAvailable = forceTouchAvailable
        }
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        super.touchesBegan(touches, withEvent: event)
        
        guard let touch = touches.first where self.forceTouchAvailable && touches.count == 1 else {
            
            self.state = .Failed
            return
        }
        
        if #available(iOS 9, *) {
            
            self.minimumForce = min(self.minimumForce, touch.maximumPossibleForce)
            self.force = touch.force
            self.state = .Began
        } else {
            
            self.state = .Failed
        }
    }
    
    override public func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        super.touchesCancelled(touches, withEvent: event)
        self.state = .Cancelled
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        super.touchesEnded(touches, withEvent: event)
        
        if self.force > self.minimumForce {
            
            self.state = .Ended
            self.vibrateIfNeeded()
        } else {
            
            self.state = .Cancelled
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        super.touchesMoved(touches, withEvent: event)
        
        if self.state == .Failed {
            
            return
        }
        
        if #available(iOS 9.0, *) {
            
            self.force = touches.first!.force
            
            if self.force > self.minimumForce {
                
                self.state = .Ended
                self.vibrateIfNeeded()
            }
        }
    }
    
    override public func reset() {
        
        super.reset()
        self.force = 0
    }
    
    private func vibrateIfNeeded() {
        
        if self.vibrationEnabled {
            
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
    }
}

private class ForceTouchCapabilityMonitor {
    
    private(set) var available = false {
        didSet {
            
            if self.available != oldValue {
                
                self.didChange?(available: self.available)
            }
        }
    }
    
    var didChange: ((available: Bool) -> Void)?
    
    private weak var capabilityView: ForceTouchCapabilityView!
    
    init() {
        
        guard let _window = UIApplication.sharedApplication().delegate?.window, let window = _window else {
            
            fatalError()
        }
        
        let capabilityView = ForceTouchCapabilityView()
        capabilityView.monitor = self
        capabilityView.hidden = true
        
        // To identify whether force touch is available. The UITraitCollection's forceTouchCapability property is .Unknown if the view is not added to app's view hierarchy.
        window.addSubview(capabilityView)
        self.capabilityView = capabilityView
        
        self.available = capabilityView.forceTouchAvailable
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.capabilityView?.removeFromSuperview()
    }
    
    dynamic func applicationDidBecomeActive(application: UIApplication) {
        
        self.available = self.capabilityView.forceTouchAvailable
    }
    
    private class ForceTouchCapabilityView: UIView {
        
        var monitor: ForceTouchCapabilityMonitor?
        
        var forceTouchAvailable: Bool {
            
            if #available(iOS 9, *) {
                
                return self.traitCollection.forceTouchCapability == .Available
            }
            return false
        }
        
        @available(iOS 8.0, *)
        override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
            
            if #available(iOS 9, *) {
                
                self.monitor?.available = self.traitCollection.forceTouchCapability == .Available
            }
        }
    }
}