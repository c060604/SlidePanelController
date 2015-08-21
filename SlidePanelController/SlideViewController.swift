//
//  SlideViewController.swift
//  SlidePanelController
//
//  Created by cxl on 15/8/12.
//  Copyright (c) 2015年 c060604. All rights reserved.
//

import UIKit

/**
panel 呈现方式

- PanelBehindCenter: panel 被 center 遮挡在下面
- PanelBesideCenter: panel 挨着 center
- PanelAboveCenter:  panel 在 center 上面
*/
public enum DisplayMode {
    case PanelBehindCenter
    case PanelBesideCenter
    case PanelAboveCenter
}


/**
panel 的状态

- BothCollapsed:      两个 panel 都收起
- LeftPanelExpanded:  left panel 打开
- RightPanelExpanded: right panel 打开
*/
enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
    case RightPanelExpanded
}


/**
*  slide controller 的控制参数
*/
public struct SlidePanelOptions {
    static var leftViewWidth: CGFloat = 270.0                       // left panel width
    static var rightViewWidth: CGFloat = 270.0                      // right panel width
    static var panelDisplayMode: DisplayMode = .PanelBehindCenter
    static var contentViewOpacity: CGFloat = 0.5                    // center view 的透明度
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
        
        switch SlidePanelOptions.panelDisplayMode {
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
        
        leftViewCenterX = SlidePanelOptions.leftViewWidth / 2
        rightViewCenterX = CGRectGetWidth(view.bounds) - SlidePanelOptions.rightViewWidth / 2
        
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

    /**
    关闭 panel
    */
    func collapseSidePanels() {
        switch currentState {
        case .LeftPanelExpanded:
            println("collapseSidePanel: leftPanelExpanded")
            toggleLeftPanel()
            break
        case .RightPanelExpanded:
            println("collapseSidePanel: rightPanelExpanded")
            toggleRightPanel()
            break
        default:
            break
        }
    }
    
    /**
    操作 left panel
    */
    override func toggleLeftPanel() {
        if currentState == .RightPanelExpanded {
            return collapseSidePanels()
        }
        
        let shouldExpanded = (currentState != .LeftPanelExpanded)
        if leftPanelViewController == nil {
            return
        }
        switch SlidePanelOptions.panelDisplayMode {
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
    
    /**
    操作 right panel
    */
    override func toggleRightPanel() {
        if currentState == .LeftPanelExpanded {
            return collapseSidePanels()
        }
        
        let shouldExpanded = (currentState != .RightPanelExpanded)
        if rightPanelViewController == nil {
            return
        }
        switch SlidePanelOptions.panelDisplayMode {
        case .PanelBehindCenter:
            animateToggleRightPanelWithPanelBehindCenterMode(shouldExpanded: shouldExpanded)
            break
        case .PanelBesideCenter:
            animateToggleRightPanelWithPanelBesideCenterMode(shouldExpanded: shouldExpanded)
            break
        case .PanelAboveCenter:
            animateToggleRightPanelWithPanelAboveCenterMode(shouldExpanded: shouldExpanded)
        default:
            break
        }
    }
    
    /**
    判断是否在操作 left panel
    
    :returns: Bool
    */
    func isTogglingLeftPanel() -> Bool {
        if leftPanelViewController != nil && (gestureDraggingFromLeftToRight && currentState == .BothCollapsed
            || currentState == .LeftPanelExpanded) {
                return true
        }
        return false
    }
    
    /**
    判断是否在操作 right panel
    
    :returns: Bool
    */
    func isTogglingRightPanel() -> Bool {
        if rightPanelViewController != nil && (!gestureDraggingFromLeftToRight && currentState == .BothCollapsed
            || currentState == .RightPanelExpanded) {
                return true
        }
        return false
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
        switch SlidePanelOptions.panelDisplayMode {
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
