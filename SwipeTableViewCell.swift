//
//  SwipeTableViewCell.swift
//  SwipeTableViewCell
//
//  Created by SEN LIU on 3/3/17.
//  Copyright © 2017 SEN LIU. All rights reserved.
//

import UIKit

public class SwipeTableViewCell: UITableViewCell {
    
    private var bgView : UIView!
    private var panGestureRecognizer : UIPanGestureRecognizer!
    
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
    }
    
    private func prepare() {
        // bgView
        bgView = UIView(frame: CGRect.zero)
        backgroundView = bgView
        bgView.backgroundColor = UIColor.green
 
        // panGesture
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwipeTableViewCell.didPan(sender:)))
        addGestureRecognizer(panGestureRecognizer)
        
        // contentView
        contentView.backgroundColor = UIColor.white
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = bounds
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
        
        if sender.state == .ended || sender.state == .cancelled {
            animateContentViewToX(0, initialVX: sender.velocity(in: self).x)
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
}
