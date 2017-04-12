//
//  SwipeTableViewCellActionView.swift
//  SwipeTableViewCell
//
//  Created by SEN LIU on 3/3/17.
//  Copyright © 2017 SEN LIU. All rights reserved.
//

import UIKit

public class SwipeTableViewCellActionView: UIView {
 
    // Outlets
    private var imageView: UIImageView!
    private var label: UILabel!
    private var contentView: UIView!
    private var tap: UITapGestureRecognizer!
    
    // State
    private(set) var currentScale: CGFloat = 1
    
    // Configurations
    public var minScale: CGFloat = 0.8
    public var maxScale: CGFloat = 1
    private(set) var handler: (() -> ())?

    //----------------------------------------------
    // MARK: - Life Cycle
    //----------------------------------------------
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentView = UIView(frame: CGRect.zero)
        addSubview(contentView)

        imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)

        label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        contentView.addSubview(label)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
 
        contentView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        contentView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
        
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -6).isActive = true
        label.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        tap = UITapGestureRecognizer(target: self, action: #selector(SwipeTableViewCellActionView.didTap(_:)))
        addGestureRecognizer(tap)
    }
    
    //----------------------------------------------
    // MARK: - User Interactions
    //----------------------------------------------
    func didTap(_ sender: UITapGestureRecognizer) {
        handler?()
    }
    
    
    //----------------------------------------------
    // MARK: - Configuration
    //----------------------------------------------
    public func configure(image: UIImage?, title: String?, handler:(()->())?) {
        imageView.image = image
        label.text = title
        self.handler = handler
    }
    
    // ======================================================= //
    // MARK: - UI
    // ======================================================= //
    public func updateContentScale(_ scale: CGFloat, animated: Bool) {
        if currentScale == scale {
            return
        }
        currentScale = scale
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.0, options: [], animations: { 
                self.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }, completion: nil)
        } else {
            self.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    public func updateToMinScale(animated: Bool) {
        updateContentScale(minScale, animated: animated)
    }
    
    public func updateToMaxScale(animated: Bool) {
        updateContentScale(maxScale, animated: animated)
    }
}
