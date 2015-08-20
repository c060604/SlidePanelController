//
//  SlideViewController+PanelBehindCenterMode.swift
//  SlidePanelController
//
//  Created by cxl on 15/8/13.
//  Copyright (c) 2015年 c060604. All rights reserved.
//

import Foundation
import UIKit


extension SlideViewController {
        
    func initViewWithPanelBehindCenterMode() {
        if let viewController = leftPanelViewController {
            let originFrame = viewController.view.frame
            let newFrame = CGRect(origin: originFrame.origin, size: CGSize(width: SlidePanleOptions.leftViewWidth, height: originFrame.height))
            viewController.view.frame = newFrame
            view.insertSubview(viewController.view, atIndex: 0)
            addChildViewController(viewController)
            viewController.didMoveToParentViewController(self)
        }
        
        if let viewController = rightPanelViewController {
            let originFrame = viewController.view.frame
            let newFrame = CGRect(origin: CGPoint(x: CGRectGetWidth(view.bounds) - SlidePanleOptions.rightViewWidth, y: 0), size: CGSize(width: SlidePanleOptions.rightViewWidth, height: originFrame.size.height))
            viewController.view.frame = newFrame
            view.insertSubview(viewController.view, atIndex: 0)
            addChildViewController(viewController)
            viewController.didMoveToParentViewController(self)
        }
    }
    
    func animateToggleLeftPanelWithPanelBehindCenterMode(#shouldExpanded: Bool) {
        if shouldExpanded {
            leftPanelViewController?.view.hidden = false
            rightPanelViewController?.view.hidden = true
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.centerViewController.view.frame.origin.x = SlidePanleOptions.leftViewWidth
                    self.opacityView.frame.origin.x = SlidePanleOptions.leftViewWidth
                    self.opacityView.layer.opacity = Float(SlidePanleOptions.contentViewOpacity)
                }, completion: { _ in
                    self.currentState = .LeftPanelExpanded
            })
        } else {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.centerViewController.view.frame.origin.x = 0
                    self.opacityView.frame.origin.x = 0
                    self.opacityView.layer.opacity = 0.0
                }, completion: { _ in
                    self.currentState = .BothCollapsed
                    self.leftPanelViewController?.view.hidden = true
                    self.rightPanelViewController?.view.hidden = true
            })
        }
    }
    
    func animateToggleRightPanelWithPanelBehindCenterMode(#shouldExpanded: Bool) {
        if shouldExpanded {
            leftPanelViewController?.view.hidden = true
            rightPanelViewController?.view.hidden = false
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.centerViewController.view.frame.origin.x = -SlidePanleOptions.rightViewWidth
                }, completion: { _ in
                    self.currentState = .RightPanelExpanded
            })
        } else {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.centerViewController.view.frame.origin.x = 0
                }, completion: { _ in
                    self.currentState = .BothCollapsed
                    self.leftPanelViewController?.view.hidden = true
                    self.rightPanelViewController?.view.hidden = true
            })
        }
    }
    
    func handlePanGestureWithPanelBehindCenterMode(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            gestureDraggingFromLeftToRight = recognizer.velocityInView(view).x > 0
            if gestureDraggingFromLeftToRight && currentState == .BothCollapsed{
                leftPanelViewController?.view.hidden = false
                rightPanelViewController?.view.hidden = true
            } else if !gestureDraggingFromLeftToRight && currentState == .BothCollapsed {
                leftPanelViewController?.view.hidden = true
                rightPanelViewController?.view.hidden = false
            }
        case .Changed:
            let centerX = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.view!.center.x = centerX
            opacityView.center.x = centerX
            
            var radio: CGFloat = 0
            if leftPanelViewController != nil && leftPanelViewController!.view.hidden == false {
                radio = CGRectGetMinX(centerViewController.view.frame) / SlidePanleOptions.leftViewWidth
            } else if rightPanelViewController != nil && rightPanelViewController!.view.hidden == false {
                radio = (CGRectGetMaxX(view.bounds) - CGRectGetMaxX(centerViewController.view.frame)) / SlidePanleOptions.rightViewWidth
            }
            opacityView.layer.opacity = Float(SlidePanleOptions.contentViewOpacity * radio)
            
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if leftPanelViewController != nil && leftPanelViewController!.view.hidden == false {
                let hasMoveGreaterThanHalfway = CGRectGetMinX(recognizer.view!.frame) > leftViewCenterX
                animateToggleLeftPanel(shouldExpanded: hasMoveGreaterThanHalfway)
            } else if rightPanelViewController != nil && rightPanelViewController!.view.hidden == false {
                let hasMoveGreaterThanHalfway = CGRectGetMaxX(recognizer.view!.frame) < rightViewCenterX
                animateToggleRightPanel(shouldExpanded: hasMoveGreaterThanHalfway)
            }
        default:
            break
        }
    }
}
