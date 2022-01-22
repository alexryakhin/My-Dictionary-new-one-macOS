//
//  Extensions(iOS).swift
//  My Dictionary (iOS)
//
//  Created by Alexander Ryakhin on 1/20/22.
//

import Foundation
import Combine
import SwiftUI
import UIKit

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for:nil)
    }
}

extension Color {
    static var background: Color {
        return Color("Background")
    }
}

//extension UINavigationController {
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//        var gradientColor = UIColor.label
//        let blue = UIColor.systemGreen
//        let purple = UIColor.systemBlue
//        
//        let largeTitleFont = UIFont.systemFont(ofSize: 35, weight: .bold)
//        let longestTitle = "My Awesome App"
//        let size = longestTitle.size(withAttributes: [.font : largeTitleFont])
//        let gradient = CAGradientLayer()
//        let bounds = CGRect(origin: navigationBar.bounds.origin, size: CGSize(width: size.width, height: navigationBar.bounds.height))
//        gradient.frame = bounds
//        gradient.colors = [blue.cgColor, purple.cgColor]
//        gradient.startPoint = CGPoint(x: 0, y: 0)
//        gradient.endPoint = CGPoint(x: 1, y: 0)
//        
//        if let image = UIImage.getImageFrom(gradientLayer: gradient) {
//            gradientColor = UIColor(patternImage: image)
//        }
//        
//        let scrollEdgeAppearance = UINavigationBarAppearance()
//        scrollEdgeAppearance.configureWithTransparentBackground()
//        
//        let standardAppearance = UINavigationBarAppearance()
//        
//        if let largeTitleDescriptor = largeTitleFont.fontDescriptor.withDesign(.rounded) {
//            scrollEdgeAppearance.largeTitleTextAttributes = [.font : UIFont(descriptor: largeTitleDescriptor, size: 0)]
//        }
//        
//        if let titleDescriptor = UIFont.systemFont(ofSize: 17.5, weight: .semibold).fontDescriptor.withDesign(.rounded) {
//            standardAppearance.titleTextAttributes = [.font : UIFont(descriptor: titleDescriptor, size: 0)]
//        }
//        
//        navigationBar.standardAppearance = standardAppearance
//                
//        navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
//    }
//}

extension UIImage {
    static func getImageFrom(gradientLayer: CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
}

