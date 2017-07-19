//
//  Utilities.swift
//  Buszzz
//
//  Created by Calios on 16/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import Foundation

public func DLog(_ format: String, _ args:CVarArg...) {
//    NSLog("<\(NSString.init(utf8String: #file)?.lastPathComponent): (\(#line))> ---- \(NSString.init(format: format as NSString, args))")
    NSLog("< ------- \(NSString.init(format: format as NSString, args))")
}

