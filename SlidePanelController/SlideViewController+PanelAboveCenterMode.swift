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
            let newFrame = CGRect(origin: CGPoint(x: -SlidePanelOptions.leftViewWidth, y: 0), size: CGSize(width: SlidePanelOptions.leftViewWidth, height: originFrame.size.height))
            viewController.view.frame = newFrame
            view.insertSubview(viewController.view, aboveSubview: opacityView)
            addChildViewController(viewController)
            viewController.didMoveToParentViewController(self)
        }
        
        if let viewController = rightPanelViewController {
            let originFrame = viewController.view.frame
            let newFrame = CGRect(origin: CGPoint(x: CGRectGetWidth(view.bounds), y: 0), size: CGSize(width: SlidePanelOptions.rightViewWidth, height: originFrame.size.height))
            viewController.view.frame = newFrame
            view.insertSubview(viewController.view, aboveSubview: opacityView)
            addChildViewController(viewController)
            viewController.didMoveToParentViewController(self)
        }
    }
        
    func animateToggleLeftPanelWithPanelAboveCenterMode(#shouldExpanded: Bool) {
        if shouldExpanded {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.leftPanelViewController?.view.frame.origin.x = 0
                    self.opacityView.layer.opacity = Float(SlidePanelOptions.contentViewOpacity)
                }, completion: { _ in
                    self.currentState = .LeftPanelExpanded
            })
        } else {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.leftPanelViewController?.view.frame.origin.x = -SlidePanelOptions.leftViewWidth
                    self.opacityView.layer.opacity = 0
                }, completion: { _ in
                    self.currentState = .BothCollapsed
            })
        }
    }
    
    func animateToggleRightPanelWithPanelAboveCenterMode(#shouldExpanded: Bool) {
        if shouldExpanded {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.rightPanelViewController?.view.frame.origin.x = CGRectGetWidth(self.view.bounds) - SlidePanelOptions.rightViewWidth
                    self.opacityView.layer.opacity = Float(SlidePanelOptions.contentViewOpacity)
                }, completion: { _ in
                    self.currentState = .RightPanelExpanded
            })
        } else {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
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
            if isTogglingLeftPanel() {
            
                var leftViewOriginX = leftPanelViewController!.view.frame.origin.x + recognizer.translationInView(view).x
                leftViewOriginX = applyLeftTranslationWithPanelAboveCenterMode(leftViewOriginX)
                leftPanelViewController!.view.frame.origin.x = leftViewOriginX
                radio = CGRectGetMaxX(leftPanelViewController!.view.frame) / SlidePanelOptions.leftViewWidth
                    
            } else if isTogglingRightPanel() {

                var rightViewOriginX = rightPanelViewController!.view.frame.origin.x + recognizer.translationInView(view).x
                rightViewOriginX = applyRightTranslationWithPanelAboveCenterMode(rightViewOriginX)
                rightPanelViewController!.view.frame.origin.x = rightViewOriginX
                radio = (CGRectGetMaxX(view.bounds) - CGRectGetMaxX(rightPanelViewController!.view.frame)) / SlidePanelOptions.rightViewWidth
                
            }
            
            opacityView.layer.opacity = Float(SlidePanelOptions.contentViewOpacity * radio)
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if isTogglingLeftPanel() {
                let hasMoveGreaterThanHalfWay = leftPanelViewController!.view.center.x > 0
                animateToggleLeftPanelWithPanelAboveCenterMode(shouldExpanded: hasMoveGreaterThanHalfWay)
            } else if isTogglingRightPanel() {
                let hasMoveGreaterThanHalfway = rightPanelViewController!.view.center.x < CGRectGetMaxX(view.frame)
                animateToggleRightPanelWithPanelAboveCenterMode(shouldExpanded: hasMoveGreaterThanHalfway)
            }
        default:
            break
        }

    }
    
    func applyLeftTranslationWithPanelAboveCenterMode(leftViewOriginX: CGFloat) -> CGFloat {
        var newLeftViewOriginX = leftViewOriginX
        if newLeftViewOriginX < -SlidePanelOptions.leftViewWidth {
            newLeftViewOriginX = -SlidePanelOptions.leftViewWidth
        } else if newLeftViewOriginX > 0 {
            newLeftViewOriginX = 0
        }
        return newLeftViewOriginX
    }
    
    func applyRightTranslationWithPanelAboveCenterMode(rightViewOriginX: CGFloat) -> CGFloat {
        var newRightViewOriginX = rightViewOriginX
        if newRightViewOriginX < CGRectGetWidth(view.bounds) - SlidePanelOptions.rightViewWidth {
            newRightViewOriginX = CGRectGetWidth(view.bounds) - SlidePanelOptions.rightViewWidth
        } else if newRightViewOriginX > CGRectGetWidth(view.bounds) {
            newRightViewOriginX = CGRectGetWidth(view.bounds)
        }
        return newRightViewOriginX
    }
}
