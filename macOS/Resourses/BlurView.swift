//
//  BlurView.swift
//  MyDictionary (macOS)
//
//  Created by Alexander Ryakhin on 6/01/21.
//

import SwiftUI

struct BlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) { }
}
