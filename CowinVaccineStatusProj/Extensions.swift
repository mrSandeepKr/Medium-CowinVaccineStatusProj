//
//  Extensions.swift
//  CowinVaccineStatusProj
//
//  Created by Sandeep Kumar on 11/09/21.
//

import Foundation
import UIKit

extension UIView {
    var height: CGFloat {
        return self.layer.frame.height
    }
    
    var width: CGFloat {
        return self.layer.frame.width
    }
    
    var bottom: CGFloat {
        return self.layer.frame.maxY
    }
}
