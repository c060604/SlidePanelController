//
//  SlideViewController+PanelBesideCenterMode.swift
//  SlidePanelController
//
//  Created by cxl on 15/8/13.
//  Copyright (c) 2015年 c060604. All rights reserved.
//

import Foundation
import UIKit


extension SlideViewController {
    
    func initViewWithPanelBesideCenterMode() {
        if let viewController = leftPanelViewController {
            let originFrame = viewController.view.frame
            let newFrame = CGRect(origin: CGPoint(x: -SlidePanelOptions.leftViewWidth, y: 0), size: CGSize(width: SlidePanelOptions.leftViewWidth, height: originFrame.size.height))
            viewController.view.frame = newFrame
            view.insertSubview(viewController.view, atIndex: 0)
            addChildViewController(viewController)
            viewController.didMoveToParentViewController(self)
        }
        
        if let viewController = rightPanelViewController {
            let originFrame = viewController.view.frame
            let newFrame = CGRect(origin: CGPoint(x: CGRectGetWidth(view.bounds), y: 0), size: CGSize(width: SlidePanelOptions.rightViewWidth, height: originFrame.size.height))
            viewController.view.frame = newFrame
            view.insertSubview(viewController.view, atIndex: 0)
            addChildViewController(viewController)
            viewController.didMoveToParentViewController(self)
        }
    }
        
    func animateToggleLeftPanelWithPanelBesideCenterMode(#shouldExpanded: Bool) {
        if shouldExpanded {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.centerViewController.view.frame.origin.x = SlidePanelOptions.leftViewWidth
                    self.opacityView.frame.origin.x = SlidePanelOptions.leftViewWidth
                    self.opacityView.layer.opacity = Float(SlidePanelOptions.contentViewOpacity)
                    self.leftPanelViewController?.view.frame.origin.x = 0
                }, completion: { _ in
                    self.currentState = .LeftPanelExpanded
            })
        } else {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.centerViewController.view.frame.origin.x = 0
                    self.opacityView.frame.origin.x = 0
                    self.opacityView.layer.opacity = 0
                    self.leftPanelViewController?.view.frame.origin.x = -SlidePanelOptions.leftViewWidth
                }, completion: { _ in
                    self.currentState = .BothCollapsed
            })
        }
    }
    
    func animateToggleRightPanelWithPanelBesideCenterMode(#shouldExpanded: Bool) {
        if shouldExpanded {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.centerViewController.view.frame.origin.x = -SlidePanelOptions.rightViewWidth
                    self.opacityView.frame.origin.x = -SlidePanelOptions.rightViewWidth
                    self.opacityView.layer.opacity = Float(SlidePanelOptions.contentViewOpacity)
                    self.rightPanelViewController?.view.frame.origin.x = CGRectGetWidth(self.view.bounds) - SlidePanelOptions.rightViewWidth
                }, completion: { _ in
                    self.currentState = .RightPanelExpanded
            })
        } else {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.centerViewController.view.frame.origin.x = 0
                    self.opacityView.frame.origin.x = 0
                    self.opacityView.layer.opacity = 0
                    self.rightPanelViewController?.view.frame.origin.x = CGRectGetWidth(self.view.bounds)
                }, completion: { _ in
                    self.currentState = .BothCollapsed
            })
        }
    }
    
    func handlePanGestureWithPanelBesideCenterMode(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            gestureDraggingFromLeftToRight = recognizer.velocityInView(view).x > 0
        case .Changed:
            var centerOriginX = centerViewController.view.frame.origin.x + recognizer.translationInView(view).x
            var radio: CGFloat = 0
            if isTogglingLeftPanel() {
                
                var leftViewOriginX = leftPanelViewController!.view.frame.origin.x + recognizer.translationInView(view).x
                (centerOriginX, leftViewOriginX) = applyLeftTranslationWithPanelBesideCenterMode(centerOriginX, leftViewOriginX: leftViewOriginX)
                leftPanelViewController!.view.frame.origin.x = leftViewOriginX
                radio = CGRectGetMinX(centerViewController.view.frame) / SlidePanelOptions.leftViewWidth
                
                
            } else if isTogglingRightPanel() {
                
                var rightViewOriginX = rightPanelViewController!.view.frame.origin.x + recognizer.translationInView(view).x
                (centerOriginX, rightViewOriginX) = applyRightTranslationWithPanelBesideCenterMode(centerOriginX, rightViewOriginX: rightViewOriginX)
                rightPanelViewController!.view.frame.origin.x = rightViewOriginX
                radio = (CGRectGetMaxX(view.bounds) - CGRectGetMaxX(centerViewController.view.frame)) / SlidePanelOptions.rightViewWidth
                    
            }
            centerViewController.view.frame.origin.x = centerOriginX
            opacityView.frame.origin.x = centerOriginX
            opacityView.layer.opacity = Float(SlidePanelOptions.contentViewOpacity * radio)
            
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if isTogglingLeftPanel() {
                let hasMoveGreaterThanHalfWay = CGRectGetMinX(recognizer.view!.frame) > leftViewCenterX
                animateToggleLeftPanelWithPanelBesideCenterMode(shouldExpanded: hasMoveGreaterThanHalfWay)
            } else if isTogglingRightPanel() {
                let hasMoveGreaterThanHalfway = CGRectGetMaxX(recognizer.view!.frame) < rightViewCenterX
                animateToggleRightPanelWithPanelBesideCenterMode(shouldExpanded: hasMoveGreaterThanHalfway)
            }
        default:
            break
        }
    }
    
    func applyLeftTranslationWithPanelBesideCenterMode(centerViewOriginX: CGFloat, leftViewOriginX: CGFloat) -> (CGFloat, CGFloat) {
        var newCenterViewOriginX = centerViewOriginX
        var newLeftViewOriginX = leftViewOriginX
        if newCenterViewOriginX < 0 {
            newCenterViewOriginX = 0
        } else if newCenterViewOriginX > SlidePanelOptions.leftViewWidth {
            newCenterViewOriginX = SlidePanelOptions.leftViewWidth
        }
        
        if newLeftViewOriginX < -SlidePanelOptions.leftViewWidth {
            newLeftViewOriginX = -SlidePanelOptions.leftViewWidth
        } else if newLeftViewOriginX > 0 {
            newLeftViewOriginX = 0
        }
        
        return (newCenterViewOriginX, newLeftViewOriginX)
    }
    
    func applyRightTranslationWithPanelBesideCenterMode(centerViewOriginX: CGFloat, rightViewOriginX: CGFloat) -> (CGFloat, CGFloat) {
        var newCenterViewOriginX = centerViewOriginX
        var newRightViewOriginX = rightViewOriginX
        if newCenterViewOriginX < -SlidePanelOptions.rightViewWidth {
            newCenterViewOriginX = -SlidePanelOptions.rightViewWidth
        } else if newCenterViewOriginX > 0 {
            newCenterViewOriginX = 0
        }
        
        if newRightViewOriginX < CGRectGetWidth(view.bounds) - SlidePanelOptions.rightViewWidth {
            newRightViewOriginX = CGRectGetWidth(view.bounds) - SlidePanelOptions.rightViewWidth
        } else if newRightViewOriginX > CGRectGetWidth(view.bounds) {
            newRightViewOriginX = CGRectGetWidth(view.bounds)
        }
        
        return (newCenterViewOriginX, newRightViewOriginX)
    }
}
