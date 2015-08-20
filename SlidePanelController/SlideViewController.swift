//
//  SlideViewController.swift
//  SlidePanelController
//
//  Created by cxl on 15/8/12.
//  Copyright (c) 2015年 c060604. All rights reserved.
//

import UIKit

public enum DisplayMode {
    case PanelBehindCenter
    case PanelBesideCenter
    case PanelAboveCenter
}


enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
    case RightPanelExpanded
}


public struct SlidePanleOptions {
    static var leftViewWidth: CGFloat = 270.0
    static var rightViewWidth: CGFloat = 270.0
    static var panelDisplayMode: DisplayMode = .PanelBehindCenter
    static var contentViewOpacity: CGFloat = 0.5
}


public class SlideViewController: UIViewController {

    var centerViewController: UIViewController!
    var leftPanelViewController: UIViewController?
    var rightPanelViewController: UIViewController?
    var opacityView: UIView!
    
    var currentState: SlideOutState = .BothCollapsed
    
    var leftViewCenterX: CGFloat = 0
    var rightViewCenterX: CGFloat = 0
    
    var gestureDraggingFromLeftToRight: Bool = true
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public convenience init(centerViewController: UIViewController, leftPanelViewController: UIViewController, rightPanelViewController: UIViewController) {
        self.init()
        self.centerViewController = centerViewController
        self.leftPanelViewController = leftPanelViewController
        self.rightPanelViewController = rightPanelViewController
        
        initView()
    }
    
    public convenience init(centerViewController: UIViewController, leftPanelViewController: UIViewController) {
        self.init()
        self.centerViewController = centerViewController
        self.leftPanelViewController = leftPanelViewController
        
        initView()
    }
    
    public convenience init(centerViewController: UIViewController, rightPanelViewController: UIViewController) {
        self.init()
        self.centerViewController = centerViewController
        self.rightPanelViewController = rightPanelViewController
        
        initView()
    }
    
    func initView() {
        view.addSubview(centerViewController.view)
        addChildViewController(centerViewController)
        centerViewController.didMoveToParentViewController(self)
        
        opacityView = UIView(frame: view.bounds)
        opacityView.backgroundColor = UIColor.blackColor()
        opacityView.layer.opacity = 0.0
        opacityView.userInteractionEnabled = false
        view.addSubview(opacityView)
        
        switch SlidePanleOptions.panelDisplayMode {
        case .PanelBehindCenter:
            initViewWithPanelBehindCenterMode()
            break
        case .PanelBesideCenter:
            initViewWithPanelBesideCenterMode()
            break
        case .PanelAboveCenter:
            initViewWithPanelAboveCenterMode()
            break
        default:
            break
        }
        
        leftViewCenterX = SlidePanleOptions.leftViewWidth / 2
        rightViewCenterX = CGRectGetWidth(view.bounds) - SlidePanleOptions.rightViewWidth / 2
        
        // 添加手势
        let panGestureRecoginzer = UIPanGestureRecognizer(target: self, action: Selector("handlePanGesture:"))
        centerViewController.view.addGestureRecognizer(panGestureRecoginzer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture:"))
        centerViewController.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collapseSidePanels() {
        switch currentState {
        case .LeftPanelExpanded:
            toggleLeftPanel()
            break
        case .RightPanelExpanded:
            toggleRightPanel()
            break
        default:
            break
        }
    }
    
    override func toggleLeftPanel() {
        if currentState == .RightPanelExpanded {
            return
        }
        
        let shouldExpanded = (currentState != .LeftPanelExpanded)
        if leftPanelViewController == nil {
            return
        }
        switch SlidePanleOptions.panelDisplayMode {
        case .PanelBehindCenter:
            animateToggleLeftPanelWithPanelBehindCenterMode(shouldExpanded: shouldExpanded)
            break
        case .PanelBesideCenter:
            animateToggleLeftPanelWithPanelBesideCenterMode(shouldExpanded: shouldExpanded)
            break
        case .PanelAboveCenter:
            animateToggleLeftPanelWithPanelAboveCenterMode(shouldExpanded: shouldExpanded)
            break
        default:
            break
        }
    }
    
    override func toggleRightPanel() {
        if currentState == .LeftPanelExpanded {
            return
        }
        
        let shouldExpanded = (currentState != .RightPanelExpanded)
        if rightPanelViewController == nil {
            return
        }
        switch SlidePanleOptions.panelDisplayMode {
        case .PanelBehindCenter:
            animateToggleRightPanelWithPanelBehindCenterMode(shouldExpanded: shouldExpanded)
            break
        case .PanelBesideCenter:
            animateToggleRightPanelWithPanelBesideCenterMode(shouldExpanded: shouldExpanded)
            break
        case .PanelAboveCenter:
            animateToggleRightPanelWithPanelAboveCenterMode(shouldExpaned: shouldExpanded)
        default:
            break
        }
    }
    
    func animateToggleLeftPanel(#shouldExpanded: Bool) {
        switch SlidePanleOptions.panelDisplayMode {
        case .PanelBehindCenter:
            animateToggleLeftPanelWithPanelBehindCenterMode(shouldExpanded: shouldExpanded)
            break
        case .PanelBesideCenter:
            animateToggleLeftPanelWithPanelBesideCenterMode(shouldExpanded: shouldExpanded)
            break
        case .PanelAboveCenter:
            animateToggleLeftPanelWithPanelAboveCenterMode(shouldExpanded: shouldExpanded)
            break
        default:
            break
        }
    }
    
    func animateToggleRightPanel(#shouldExpanded: Bool) {
        switch SlidePanleOptions.panelDisplayMode {
        case .PanelBehindCenter:
            animateToggleRightPanelWithPanelBehindCenterMode(shouldExpanded: shouldExpanded)
            break
        case .PanelBesideCenter:
            animateToggleRightPanelWithPanelBesideCenterMode(shouldExpanded: shouldExpanded)
            break
        case .PanelAboveCenter:
            animateToggleRightPanelWithPanelAboveCenterMode(shouldExpaned: shouldExpanded)
            break
        default:
            break
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension SlideViewController: UIGestureRecognizerDelegate {
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        switch SlidePanleOptions.panelDisplayMode {
        case .PanelBehindCenter:
            handlePanGestureWithPanelBehindCenterMode(recognizer)
            break
        case .PanelBesideCenter:
            handlePanGestureWithPanelBesideCenterMode(recognizer)
            break
        case .PanelAboveCenter:
            handlePanGestureWithPanelAboveCenterMode(recognizer)
            break
        default:
            break
        }
    }
    
    func handleTapGesture(recognizer: UITapGestureRecognizer) {
        collapseSidePanels()
    }
}


extension UIViewController {
    
    func sliderController() -> SlideViewController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is SlideViewController {
                return viewController as? SlideViewController
            }
            viewController = viewController!.parentViewController
        }
        return nil
    }
    
    func toggleLeftPanel() {
        sliderController()?.toggleLeftPanel()
    }
    
    func toggleRightPanel() {
        sliderController()?.toggleRightPanel()
    }
}
