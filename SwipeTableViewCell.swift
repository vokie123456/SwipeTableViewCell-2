//
//  SwipeTableViewCell.swift
//  SwipeTableViewCell
//
//  Created by SEN LIU on 3/3/17.
//  Copyright © 2017 SEN LIU. All rights reserved.
//

import UIKit

public class SwipeTableViewCell: UITableViewCell {
    
    private enum SwipeMode {
        case left, right, none
    }
    
    private enum OpenMode {
        case left, right, none
    }
    
    private enum FlyMode {
        case left, right, none
    }
    
    // Views
    private var bgView : UIView!
    private var leftActionContainer: UIView!
    private var rightActionContainer: UIView!
    private var panGestureRecognizer : UIPanGestureRecognizer!
    private var leftActionViews: [SwipeTableViewCellActionView] = []
    private var rightActionViews: [SwipeTableViewCellActionView] = []
    private var leftContainerMask: UIView!
    private var rightContainerMask: UIView!
    
    // States
    private var swipeMode: SwipeMode = .none
    private var openMode: OpenMode = .none
    private var flyMode: FlyMode = .none

    // Layouts
    public var actionWidth: CGFloat = 70 {
        didSet {
            setNeedsLayout()
        }
    }
    public var spaceBetweenActions: CGFloat = 2 {
        didSet {
            setNeedsLayout()
        }
    }
    public var actionHorizontalSpace: CGFloat = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    public var openTriggerVX: CGFloat = 700
    public var closeTriggerVC: CGFloat = 100
    public var openMargin: CGFloat = 20
    public var flyMargin: CGFloat = 40
    private var springMargin: CGFloat {
        get {
            return flyMargin + 40
        }
    }
    
    //----------------------------------------------
    // MARK - Life Cycle
    //----------------------------------------------
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        prepare()
    }
    
    private func prepare() {
        // bgView
        bgView = UIView(frame: CGRect.zero)
        backgroundView = bgView
        
        // action container
        leftActionContainer =  UIView(frame: CGRect.zero)
        rightActionContainer = UIView(frame: CGRect.zero)
        leftActionContainer.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        rightActionContainer.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        bgView.addSubview(leftActionContainer)
        bgView.addSubview(rightActionContainer)
        
        // action container mask
        leftContainerMask = UIView(frame: CGRect.zero)
        rightContainerMask = UIView(frame: CGRect.zero)
        leftContainerMask.backgroundColor = UIColor.white
        rightContainerMask.backgroundColor = UIColor.white
        leftActionContainer.addSubview(leftContainerMask)
        rightActionContainer.addSubview(rightContainerMask)
 
        // panGesture
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwipeTableViewCell.didPan(sender:)))
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        // contentView
        contentView.backgroundColor = UIColor.green
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = bounds
        leftActionContainer.frame = bounds
        rightActionContainer.frame = bounds
        
        for (i, view) in leftActionViews.enumerated() {
            let x = actionWidth * CGFloat(i) + spaceBetweenActions * CGFloat(i) + actionHorizontalSpace
            view.frame = CGRect(x: x, y: 0, width: actionWidth, height: bounds.height)
        }
        var minX: CGFloat = 0
        if let av = leftActionViews.last {
            minX = bounds.width - (bounds.width - av.frame.maxX) / 2
        }
        leftContainerMask.frame = CGRect(x: minX, y: 0, width: bounds.width, height: bounds.height)
        
        for (i, view) in rightActionViews.enumerated() {
            let x = bounds.width - actionWidth * CGFloat(i + 1) - spaceBetweenActions * CGFloat(i) - actionHorizontalSpace
            view.frame = CGRect(x: x, y: 0, width: actionWidth, height: bounds.height)
        }
        var maxX = bounds.maxX
        if let av = rightActionViews.last {
            maxX = (bounds.width - av.frame.minX) / 2
        }
        rightContainerMask.frame = CGRect(x: 0, y: 0, width: maxX, height: bounds.height)
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGestureRecognizer {
            let velocity = panGestureRecognizer.velocity(in: self)
            if abs(velocity.y) > abs(velocity.x) {
                return false
            }
            return true 
        } else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
    }
    
    public override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    
    //----------------------------------------------
    // MARK - User Interactions
    //----------------------------------------------
    @objc private func didPan(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self)
        let v = sender.velocity(in: self)
        
        
        let currentFrame = contentView.frame
        let newFrame = calculateSwipeDestinationFrame(currentFrame: currentFrame, translation: translation)
        contentView.frame = newFrame
        
        if swipeMode == .none {
            if newFrame.minX > 0 {
                swipeMode = .left
            } else if newFrame.minX < 0 {
                swipeMode = .right
            }
        }
        
        if sender.state == .ended || sender.state == .cancelled {
            updateOpenModeAfterSwipe(oldFrame: currentFrame, newFrame: newFrame, velocity: v) {}
            swipeMode = .none
        }
        
        sender.setTranslation(CGPoint(x:0, y:0), in: self)

        updateActionContrainers(contentViewFrame: newFrame)
        updateActionViewScales(contentViewFrame: newFrame, animated: true)
    }
    
    private func updateOpenModeAfterSwipe(oldFrame: CGRect, newFrame: CGRect, velocity: CGPoint, complete: ( () -> () )? ) {
        let vx = velocity.x
        switch swipeMode {
        case .left:
            if velocity.x > openTriggerVX {
                updateOpenMode(.left, initialVX: vx)
            } else if velocity.x < -closeTriggerVC {
                updateOpenMode(.none, initialVX: vx)
            } else if let v = leftActionViews.first {
                if newFrame.minX > v.frame.maxX {
                    updateOpenMode(.left, initialVX: vx)
                } else {
                    updateOpenMode(.none, initialVX: vx)
                }
            }
        case .right:
            if velocity.x < -openTriggerVX {
                updateOpenMode(.right, initialVX: vx)
            } else if velocity.x > closeTriggerVC {
                updateOpenMode(.none, initialVX: vx)
            } else if let v = rightActionViews.first {
                if newFrame.maxX < v.frame.minX {
                    updateOpenMode(.right, initialVX: vx)
                } else {
                    updateOpenMode(.none, initialVX: vx)
                }
            }
        case .none:
            break
        }
    }
    
    private func updateOpenMode(_ mode: OpenMode, initialVX vx: CGFloat, complete: ( () -> () )? = nil) {
        switch mode {
        case .left:
            openContentView(openMode: .left, initialVX: vx, animated: true) {
                complete?()
            }
            openMode = .left
        case .right:
            openContentView(openMode: .right, initialVX: vx, animated: true) {
                complete?()
            }
            openMode = .right
        case .none:
            closeContentView(initialVX: vx, aniamted: true) {
                complete?()
            }
            openMode = .none
        }
    }
    
    private func calculateSwipeDestinationFrame(currentFrame: CGRect, translation: CGPoint) -> CGRect {
        
        var newFrame = contentView.frame
        var factor: CGFloat = 1
        var range : (min: CGFloat, max: CGFloat)? = nil
        switch swipeMode {
        case .left:
            range = leftSmoothRange()
        case .right:
            range = rightSoothRange()
        default:
            break
        }
        if let range = range {
            if currentFrame.minX > range.max && translation.x > 0 {
                factor = min(5 / (currentFrame.minX - range.max), 1)
            } else if currentFrame.minX < range.min && translation.x < 0 {
                factor = min(5 / (range.min - currentFrame.minX), 1)
            }
        }
        newFrame.origin.x += translation.x * factor
        return newFrame
    }
    
    private func updateActionContrainers(contentViewFrame frame: CGRect) {
        switch swipeMode {
        case .left:
            leftActionContainer.isHidden = false
            rightActionContainer.isHidden = true
            leftContainerMask.isHidden = frame.minX > 0
        case .right:
            leftActionContainer.isHidden = true
            rightActionContainer.isHidden = false
            rightContainerMask.isHidden = frame.minX < 0
        default:
            break
        }
    }
    
    private func updateActionViewScales(contentViewFrame frame: CGRect, animated: Bool) {
        switch swipeMode {
        case .left:
            for v in leftActionViews {
                if frame.minX > v.frame.midX {
                    v.updateToMaxScale(animated: animated)
                } else {
                    v.updateToMinScale(animated: animated)
                }
            }
        case .right:
            for v in rightActionViews {
                if frame.maxX < v.frame.midX {
                    v.updateToMaxScale(animated: animated)
                } else {
                    v.updateToMinScale(animated: animated)
                }
            }
        default:
            break
        }
    }
    
    //----------------------------------------------
    // MARK - UI
    //----------------------------------------------
    private func moveContentViewToX(_ x: CGFloat, initialVX: CGFloat, animated: Bool, complete: ( () -> () )?) {
        let x0 =  contentView.frame.origin.x
        if x0 == x {
            return
        }
        let dx = x - x0
        let v : CGFloat = initialVX / dx
        let duration: TimeInterval = animated ? 0.6 : 0.0
        let damping: CGFloat = 1.0
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: v, options: [.allowUserInteraction], animations: {
            [weak self] in
            guard var frame = self?.contentView.frame else {
                return
            }
            frame.origin.x = x
            self?.contentView.frame = frame
        }) { (flag) in
            complete?()
        }
    }
    
    private func closeContentView(initialVX: CGFloat, aniamted: Bool, complete: ( () -> () )?) {
        moveContentViewToX(0, initialVX: initialVX, animated: aniamted, complete: complete)
        for v in leftActionViews + rightActionViews {
            v.updateToMinScale(animated: true)
        }
    }
    
    private func openContentView(openMode: OpenMode, initialVX: CGFloat, animated: Bool, complete: ( () -> () )? ) {
        var destX: CGFloat = 0
        switch openMode {
        case .left:
            if let v = leftActionViews.last {
                destX = v.frame.maxX + openMargin
            }
            for v in leftActionViews {
                v.updateToMaxScale(animated: true)
            }
        case .right:
            if let v = rightActionViews.last {
                destX = -(bounds.width - v.frame.minX + openMargin)
            }
            for v in rightActionViews {
                v.updateToMaxScale(animated: true)
            }
        default:
            break
        }
        moveContentViewToX(destX, initialVX: initialVX, animated: animated, complete: complete)
    }
    
    private func updateFlyModeWhileSwiping(contentViewFrame cvFrame: CGRect, swipeMode: SwipeMode) {
//        switch swipeMode {
//        case .left:
//            
//        case .right:
//            
//        case .none:
//            break
//        }
    }
    
    //----------------------------------------------
    // MARK - Configuration
    //----------------------------------------------
    public func configure(leftActions: [SwipeTableViewCellAction]?, rightActions: [SwipeTableViewCellAction]?) {
        
        if let leftActions = leftActions {
            prepareLeftActionViews(num: leftActions.count)
            for (i, action) in leftActions.enumerated() {
                leftActionViews[i].configure(image: action.image, title: action.title, handler: {
                    [weak self] in
                    if let sself = self {
                        action.handler?(sself)
                    }
                })
            }
        } else {
            prepareLeftActionViews(num: 0)
        }
        if let rightActions = rightActions {
            prepareRightActionViews(num: rightActions.count)
            for (i, action) in rightActions.enumerated() {
                rightActionViews[i].configure(image: action.image, title: action.title, handler: {
                    [weak self] in
                    if let sself = self {
                        action.handler?(sself)
                    }
                })
            }
        } else {
            prepareRightActionViews(num: 0)
        }
    }
    
    private func prepareLeftActionViews(num: Int) {
        if leftActionViews.count == num {
            return
        }
        if leftActionViews.count < num {
            let toCreate = num - leftActionViews.count
            for _ in 0..<toCreate {
                let view = SwipeTableViewCellActionView(frame: CGRect.zero)
                leftActionContainer.addSubview(view)
                leftActionViews.append(view)
            }
        }
    }
    
    private func prepareRightActionViews(num: Int) {
        if rightActionViews.count == num {
            return
        }
        if rightActionViews.count < num {
            let toCreate = num - rightActionViews.count
            for _ in 0..<toCreate {
                let view = SwipeTableViewCellActionView(frame: CGRect.zero)
                rightActionContainer.addSubview(view)
                rightActionViews.append(view)
            }
        }
    }
    
    //----------------------------------------------
    // MARK - UI Helpers
    //----------------------------------------------
    private func leftSmoothRange() -> (min: CGFloat, max: CGFloat) {
        if let av = leftActionViews.last {
            return (min: 0, max: av.frame.maxX + springMargin)
        } else {
            return (min: 0, max: 0)
        }
    }
    
    private func rightSoothRange() -> (min: CGFloat, max: CGFloat) {
        if let av = rightActionViews.last {
            return (min: av.frame.minX - springMargin - bounds.width, max: 0)
        } else {
            return (min: 0, max: 0)
        }
    }
}
