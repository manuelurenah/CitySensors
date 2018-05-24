//
//  String+Extension.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/22/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /// Taken from https://stackoverflow.com/a/38809531
    func convertToImage() -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()

        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))

        self.draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
