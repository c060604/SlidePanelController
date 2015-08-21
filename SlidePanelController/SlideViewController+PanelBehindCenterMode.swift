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
            let newFrame = CGRect(origin: originFrame.origin, size: CGSize(width: SlidePanelOptions.leftViewWidth, height: originFrame.height))
            viewController.view.frame = newFrame
            view.insertSubview(viewController.view, atIndex: 0)
            addChildViewController(viewController)
            viewController.didMoveToParentViewController(self)
        }
        
        if let viewController = rightPanelViewController {
            let originFrame = viewController.view.frame
            let newFrame = CGRect(origin: CGPoint(x: CGRectGetWidth(view.bounds) - SlidePanelOptions.rightViewWidth, y: 0), size: CGSize(width: SlidePanelOptions.rightViewWidth, height: originFrame.size.height))
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
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.centerViewController.view.frame.origin.x = SlidePanelOptions.leftViewWidth
                    self.opacityView.frame.origin.x = SlidePanelOptions.leftViewWidth
                    self.opacityView.layer.opacity = Float(SlidePanelOptions.contentViewOpacity)
                }, completion: { _ in
                    self.currentState = .LeftPanelExpanded
            })
        } else {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
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
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.centerViewController.view.frame.origin.x = -SlidePanelOptions.rightViewWidth
                    self.opacityView.frame.origin.x = -SlidePanelOptions.rightViewWidth
                    self.opacityView.layer.opacity = Float(SlidePanelOptions.contentViewOpacity)
                }, completion: { _ in
                    self.currentState = .RightPanelExpanded
            })
        } else {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: .CurveEaseInOut,
                animations: {
                    self.centerViewController.view.frame.origin.x = 0
                    self.opacityView.frame.origin.x = 0
                    self.opacityView.layer.opacity = 0
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
            if isOpeningLeftPanel() {
                leftPanelViewController?.view.hidden = false
                rightPanelViewController?.view.hidden = true
            } else if isOpeningRightPanel() {
                leftPanelViewController?.view.hidden = true
                rightPanelViewController?.view.hidden = false
            }
        case .Changed:
            var originX = centerViewController.view.frame.origin.x + recognizer.translationInView(view).x
            
            var radio: CGFloat = 0
            if isTogglingLeftPanel() {
                radio = CGRectGetMinX(centerViewController.view.frame) / SlidePanelOptions.leftViewWidth
                originX = applyLeftTranslationWithPanelBehindCenterMode(originX)
            } else if isTogglingRightPanel() {
                radio = (CGRectGetMaxX(view.bounds) - CGRectGetMaxX(centerViewController.view.frame)) / SlidePanelOptions.rightViewWidth
                originX = applyRightTranslationWithPanelBehindCenterMode(originX)
            }
            centerViewController.view.frame.origin.x = originX
            opacityView.frame.origin.x = originX
            opacityView.layer.opacity = Float(SlidePanelOptions.contentViewOpacity * radio)
            
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if isTogglingLeftPanel() {
                let hasMoveGreaterThanHalfway = CGRectGetMinX(recognizer.view!.frame) > leftViewCenterX
                animateToggleLeftPanelWithPanelBehindCenterMode(shouldExpanded: hasMoveGreaterThanHalfway)
            } else if isTogglingRightPanel() {
                let hasMoveGreaterThanHalfway = CGRectGetMaxX(recognizer.view!.frame) < rightViewCenterX
                animateToggleRightPanelWithPanelBehindCenterMode(shouldExpanded: hasMoveGreaterThanHalfway)
            }
        default:
            break
        }
    }
    
    /**
    判断是否打开 left panel
    
    :returns: Bool
    */
    func isOpeningLeftPanel() -> Bool {
        if leftPanelViewController != nil && gestureDraggingFromLeftToRight && (currentState == .BothCollapsed
            || currentState == .LeftPanelExpanded) {
            return true
        }
        return false
    }
    
    /**
    判断是否打开 right panel
    
    :returns: Bool
    */
    func isOpeningRightPanel() -> Bool {
        if rightPanelViewController != nil && !gestureDraggingFromLeftToRight && (currentState == .BothCollapsed
            || currentState == .RightPanelExpanded) {
            return true
        }
        return false
    }
    
    func applyLeftTranslationWithPanelBehindCenterMode(centerViewOriginX: CGFloat) -> CGFloat {
        var originX = centerViewOriginX
        if originX < 0 {
            originX = 0
        } else if originX > SlidePanelOptions.leftViewWidth {
            originX = SlidePanelOptions.leftViewWidth
        }
        return originX
    }
    
    func applyRightTranslationWithPanelBehindCenterMode(centerViewOriginX: CGFloat) -> CGFloat {
        var originX = centerViewOriginX
        if originX < -SlidePanelOptions.rightViewWidth {
            originX = -SlidePanelOptions.rightViewWidth
        } else if originX > 0 {
            originX = 0
        }
        return originX
    }
}
