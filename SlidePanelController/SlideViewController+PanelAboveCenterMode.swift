//
//  SlideViewController+PanelAboveCenterMode.swift
//  SlidePanelController
//
//  Created by cxl on 15/8/13.
//  Copyright (c) 2015年 c060604. All rights reserved.
//

import Foundation
import UIKit


extension SlideViewController {
    
    func initViewWithPanelAboveCenterMode() {
        if let viewController = leftPanelViewController {
            let originFrame = viewController.view.frame
            let newFrame = CGRect(origin: CGPoint(x: -SlidePanleOptions.leftViewWidth, y: 0), size: CGSize(width: SlidePanleOptions.leftViewWidth, height: originFrame.size.height))
            viewController.view.frame = newFrame
            view.insertSubview(viewController.view, aboveSubview: opacityView)
            addChildViewController(viewController)
            viewController.didMoveToParentViewController(self)
        }
        
        if let viewController = rightPanelViewController {
            let originFrame = viewController.view.frame
            let newFrame = CGRect(origin: CGPoint(x: CGRectGetWidth(view.bounds), y: 0), size: CGSize(width: SlidePanleOptions.rightViewWidth, height: originFrame.size.height))
            viewController.view.frame = newFrame
            view.insertSubview(viewController.view, aboveSubview: opacityView)
            addChildViewController(viewController)
            viewController.didMoveToParentViewController(self)
        }
    }
        
    func animateToggleLeftPanelWithPanelAboveCenterMode(#shouldExpanded: Bool) {
        if shouldExpanded {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.leftPanelViewController?.view.frame.origin.x = 0
                    self.opacityView.layer.opacity = Float(SlidePanleOptions.contentViewOpacity)
                }, completion: { _ in
                    self.currentState = .LeftPanelExpanded
            })
        } else {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.leftPanelViewController?.view.frame.origin.x = -SlidePanleOptions.leftViewWidth
                    self.opacityView.layer.opacity = 0
                }, completion: { _ in
                    self.currentState = .BothCollapsed
            })
        }
    }
    
    func animateToggleRightPanelWithPanelAboveCenterMode(#shouldExpaned: Bool) {
        if shouldExpaned {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.rightPanelViewController?.view.frame.origin.x = CGRectGetWidth(self.view.bounds) - SlidePanleOptions.rightViewWidth
                    self.opacityView.layer.opacity = Float(SlidePanleOptions.contentViewOpacity)
                }, completion: { _ in
                    self.currentState = .RightPanelExpanded
            })
        } else {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.rightPanelViewController?.view.frame.origin.x = CGRectGetWidth(self.view.bounds)
                    self.opacityView.layer.opacity = 0
                }, completion: { _ in
                    self.currentState = .BothCollapsed
            })
        }
    }
    
    func handlePanGestureWithPanelAboveCenterMode(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            gestureDraggingFromLeftToRight = recognizer.velocityInView(view).x > 0
        case .Changed:
            var radio: CGFloat = 0
            if leftPanelViewController != nil && (gestureDraggingFromLeftToRight && currentState == .BothCollapsed
                || !gestureDraggingFromLeftToRight && currentState == .LeftPanelExpanded) {
            
                leftPanelViewController!.view.center.x = leftPanelViewController!.view.center.x + recognizer.translationInView(view).x
                radio = CGRectGetMaxX(leftPanelViewController!.view.frame) / SlidePanleOptions.leftViewWidth
                    
            } else if rightPanelViewController != nil && (!gestureDraggingFromLeftToRight && currentState == .BothCollapsed
                || gestureDraggingFromLeftToRight && currentState == .RightPanelExpanded) {

                rightPanelViewController!.view.center.x = rightPanelViewController!.view.center.x + recognizer.translationInView(view).x
                radio = (CGRectGetMaxX(view.bounds) - CGRectGetMaxX(rightPanelViewController!.view.frame)) / SlidePanleOptions.rightViewWidth
                
            }
            
            opacityView.layer.opacity = Float(SlidePanleOptions.contentViewOpacity * radio)
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if leftPanelViewController != nil && gestureDraggingFromLeftToRight && currentState == .BothCollapsed {
                let hasMoveGreaterThanHalfWay = leftPanelViewController!.view.center.x > 0
                animateToggleLeftPanel(shouldExpanded: hasMoveGreaterThanHalfWay)
            } else if leftPanelViewController != nil && !gestureDraggingFromLeftToRight && currentState == .LeftPanelExpanded {
                let hasMoveGreaterThanHalfWay = leftPanelViewController!.view.center.x > 0
                animateToggleLeftPanel(shouldExpanded: hasMoveGreaterThanHalfWay)
            } else if rightPanelViewController != nil && !gestureDraggingFromLeftToRight && currentState == .BothCollapsed {
                let hasMoveGreaterThanHalfWay = rightPanelViewController!.view.center.x < CGRectGetMaxX(view.frame)
                animateToggleRightPanel(shouldExpanded: hasMoveGreaterThanHalfWay)
            } else {
                let hasMoveGreaterThanHalfway = rightPanelViewController!.view.center.x < CGRectGetMaxX(view.frame)
                animateToggleRightPanel(shouldExpanded: hasMoveGreaterThanHalfway)
            }
        default:
            break
        }

    }
}
