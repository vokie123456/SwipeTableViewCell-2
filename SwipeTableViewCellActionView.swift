//
//  SwipeTableViewCellActionView.swift
//  SwipeTableViewCell
//
//  Created by SEN LIU on 3/3/17.
//  Copyright © 2017 SEN LIU. All rights reserved.
//

import UIKit

public class SwipeTableViewCellActionView: UIView {
    
    private(set) public var action: SwipeTableViewCellAction!
    private var didPrepare = false
    private(set) var imageView: UIImageView!
    private(set) var label: UILabel!
    private(set) var contentView: UIView!
    
    //----------------------------------------------
    // MARK: Factories
    //----------------------------------------------
    class func viewWithAction(_ action: SwipeTableViewCellAction) -> SwipeTableViewCellActionView {
        let view = SwipeTableViewCellActionView(frame: CGRect.zero)
        view.action = action
        return view
    }
    
    //----------------------------------------------
    // MARK: Life Cycle
    //----------------------------------------------
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if !didPrepare {
            didPrepare = true
            prepare()
        }
    }
    
    private func prepare() {
        contentView = UIView(frame: CGRect.zero)
        addSubview(contentView)

        imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = action.image
        contentView.addSubview(imageView)

        label = UILabel(frame: CGRect.zero)
        label.text = action.title
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        addSubview(label)
        
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
    }
}
