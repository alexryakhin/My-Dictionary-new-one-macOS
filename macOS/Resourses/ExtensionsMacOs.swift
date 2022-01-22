//
//  ExtensionsMacOs.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI

extension NSTextField{
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
