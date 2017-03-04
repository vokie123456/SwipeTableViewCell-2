//
//  SwipeTableViewCell.swift
//  SwipeTableViewCell
//
//  Created by SEN LIU on 3/3/17.
//  Copyright © 2017 SEN LIU. All rights reserved.
//

import UIKit

public class SwipeTableViewCell: UITableViewCell {
    
    private enum ActionMode {
        case left, right, none
    }
    
    private var actionMode: ActionMode = .none {
        didSet {
            updateActionContainers()
        }
    }
    private var bgView : UIView!
    private var leftActionContainer: UIView!
    private var rightActionContainer: UIView!
    private var panGestureRecognizer : UIPanGestureRecognizer!
    private var leftActionViews: [SwipeTableViewCellActionView] = []
    private var rightActionViews: [SwipeTableViewCellActionView] = []
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
    
    //----------------------------------------------
    // MARK: Life Cycle
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
        prepare()
        updateActionContainers()
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
 
        // panGesture
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwipeTableViewCell.didPan(sender:)))
        addGestureRecognizer(panGestureRecognizer)
        
        // contentView
        contentView.backgroundColor = UIColor.white
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
        
        for (i, view) in rightActionViews.enumerated() {
            let x = bounds.width - actionWidth * CGFloat(i + 1) - spaceBetweenActions * CGFloat(i) - actionHorizontalSpace
            view.frame = CGRect(x: x, y: 0, width: actionWidth, height: bounds.height)
        }
    }
 
    //----------------------------------------------
    // MARK: UI
    //----------------------------------------------
    private func updateActionContainers() {
        switch actionMode {
        case .left:
            leftActionContainer.isHidden = false
            rightActionContainer.isHidden = true
        case .right:
            leftActionContainer.isHidden = true
            rightActionContainer.isHidden = false
        default:
            break
        }
    }
    
    //----------------------------------------------
    // MARK: User Interactions
    //----------------------------------------------
    @objc private func didPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        var newFrame = contentView.frame
        newFrame.origin.x += translation.x
        contentView.frame = newFrame
        sender.setTranslation(CGPoint(x:0, y:0), in: self)
        if actionMode == .none {
            if translation.x > 0 {
                actionMode = .left
            } else if translation.x < 0 {
                actionMode = .right
            }
        }
        if sender.state == .ended || sender.state == .cancelled {
            animateContentViewToX(0, initialVX: sender.velocity(in: self).x)
            actionMode = .none
        }
    }
    
    //----------------------------------------------
    // MARK: Animatation
    //----------------------------------------------
    private func animateContentViewToX(_ x: CGFloat, initialVX: CGFloat) {
        let x0 =  contentView.frame.origin.x
        if x0 == x {
            return
        }
        let dx = x - x0
        let v : CGFloat = initialVX / dx
        let duration: TimeInterval = 0.8
        let damping: CGFloat = 0.98
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: v, options: [], animations: {
            [weak self] in
            guard var frame = self?.contentView.frame else {
                return
            }
            frame.origin.x = x
            self?.contentView.frame = frame
        }) { (flag) in
        
        }
    }
    
    //----------------------------------------------
    // MARK: Configuration
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
}
