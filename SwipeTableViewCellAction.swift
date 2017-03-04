//
//  SwipeTableViewCellAction.swift
//  SwipeTableViewCell
//
//  Created by SEN LIU on 3/3/17.
//  Copyright © 2017 SEN LIU. All rights reserved.
//

import UIKit

public class SwipeTableViewCellAction {
    public let image: UIImage
    public let title: String
    public let handler: ((SwipeTableViewCell) -> ())?
    
    init(image: UIImage, title: String, handler: ((SwipeTableViewCell) -> ())? ) {
        self.image = image
        self.title = title
        self.handler = handler
    }
}
