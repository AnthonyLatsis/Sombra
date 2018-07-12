//
//  Sombra.swift
//  Sombra
//
//  Created by Anthony Latsis on 7/13/18.
//  Copyright © 2018 Anthony Latsis. All rights reserved.
//

import Foundation

extension UIImage {
    func applyBlur(blurRadius:CGFloat) -> UIImage?{
        
        guard let ciImage = CIImage(image: self) else {return nil}
        
        if let filter = CIFilter(name: "CIGaussianBlur") {
            
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
            let eaglContext =
                EAGLContext(api: EAGLRenderingAPI.openGLES3)
                    ??  EAGLContext(api: EAGLRenderingAPI.openGLES2)
                    ??  EAGLContext(api: EAGLRenderingAPI.openGLES1)
            
            let context = eaglContext == nil ?
                CIContext(options: nil)
                : CIContext(eaglContext: eaglContext!)
            
            if let output = filter.outputImage,
                let cgimg = context.createCGImage(output, from: ciImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return nil
    }
}

private var AssociatedShadowImageHandle: UInt8 = 0
private var AssociatedShadowLayerHandle: UInt8 = 1

public extension CALayer {
    public var shadowImage: CGImage? {
        set(value) {
            objc_setAssociatedObject(self, &AssociatedShadowImageHandle, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            object_setClass(self, Sombra.self)

            if let _ = value {
                if shadowLayer == nil {
                    let layer = CALayer()
                    addSublayer(layer)
                    shadowLayer = layer
                } else {
                    defer {
                        self.layoutIfNeeded()
                    }
                }
            } else { self.layoutIfNeeded() }
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedShadowImageHandle) as! CGImage?
        }
    }
    
    fileprivate var shadowLayer: CALayer? {
        set(value) {
            objc_setAssociatedObject(self, &AssociatedShadowLayerHandle, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.layoutIfNeeded()
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedShadowLayerHandle) as! CALayer?
        }
    }
}

class Sombra: CALayer {
    override func layoutSublayers() {
        super.layoutSublayers()
        
        if let image = shadowImage, let shadow = shadowLayer {
            //            if self.sublayers?.contains(shadow) == true { return }
            
            let inset: CGFloat = shadowRadius * 4
            
            shadow.frame = self.bounds
                .insetBy(dx: -inset, dy: -inset)
                .offsetBy(dx: shadowOffset.width, dy: shadowOffset.height)
            shadow.opacity = shadowOpacity
            
            UIGraphicsBeginImageContext(shadow.bounds.size)
            let currentContext = UIGraphicsGetCurrentContext()!
            currentContext.draw(image, in: shadow.bounds.insetBy(dx: inset, dy: inset))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let bezier = UIBezierPath.init(rect: shadow.bounds)
            bezier.append(UIBezierPath.init(rect: shadow.bounds
                .insetBy(dx: inset, dy: inset)
                .offsetBy(dx: -shadowOffset.width, dy: -shadowOffset.height)).reversing())
            
            let mask = CAShapeLayer()
            mask.path = bezier.cgPath
            
            shadow.contents = result?.applyBlur(blurRadius: shadowRadius)?.cgImage
            shadow.mask = mask
            
            shadowOpacity = 0
        }
    }
}
