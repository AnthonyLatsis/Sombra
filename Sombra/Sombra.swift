//
//  Sombra.swift
//  Sombra
//
//  Created by Anthony Latsis on 7/13/18.
//  Copyright © 2018 Anthony Latsis. All rights reserved.
//

import Foundation

extension UIImage {
    func sombraEffect(blurRadius: CGFloat) -> UIImage? {

        guard let inputImage = CIImage(image: self) else { return nil }

        if let blurFilter = CIFilter(name: "CIGaussianBlur"),
           let saturationFilter = CIFilter(name: "CIColorControls") {

            var outputImage: CIImage? = nil
           
            saturationFilter.setValue(inputImage, forKey: kCIInputImageKey)
            saturationFilter.setValue(1.8, forKey: kCIInputSaturationKey)

            outputImage = saturationFilter.outputImage

            blurFilter.setValue(outputImage, forKey: kCIInputImageKey)
            blurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)

            outputImage = blurFilter.outputImage

            let eaglContext = EAGLContext(api: EAGLRenderingAPI.openGLES3)
                ??  EAGLContext(api: EAGLRenderingAPI.openGLES2)
                ??  EAGLContext(api: EAGLRenderingAPI.openGLES1)

            let context = eaglContext == nil
                ? CIContext(options: nil)
                : CIContext(eaglContext: eaglContext!)

            if let output = outputImage,
               let img = context.createCGImage(output, from: inputImage.extent) {
                return UIImage(cgImage: img)
            }
        }
        return nil
    }
}

private var AssociatedShadowImageHandle: UInt8 = 0
private var AssociatedShadowLayerHandle: UInt8 = 1
private var AssociatedShadowOpacityHandle: UInt8 = 2

public extension CALayer {

    public var shadowImage: CGImage? {
        set(value) {
            objc_setAssociatedObject(self, &AssociatedShadowImageHandle, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            object_setClass(self, Sombra.self)

            if let _ = value {
                if shadowLayer == nil {
                    cachedShadowOpacity = shadowOpacity
                }
                shadowOpacity = 0
                shadowLayer?.removeFromSuperlayer()
                let layer = CALayer()
                layer.zPosition = CGFloat(-Float.greatestFiniteMagnitude)
                addSublayer(layer)
                shadowLayer = layer
            } else {
                shadowOpacity = cachedShadowOpacity
                shadowLayer?.removeFromSuperlayer()
                shadowLayer = nil
            }
            self.layoutIfNeeded()
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

    fileprivate var cachedShadowOpacity: Float {
        set(value) {
            objc_setAssociatedObject(self, &AssociatedShadowOpacityHandle, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedShadowOpacityHandle) as! Float
        }
    }
}

class Sombra: CALayer {

    override func layoutSublayers() {
        super.layoutSublayers()

        if let image = shadowImage, let shadow = shadowLayer {

            let inset: CGFloat = shadowRadius * 4

            shadow.frame = self.bounds
                .insetBy(dx: -inset, dy: -inset)
                .offsetBy(dx: shadowOffset.width, dy: shadowOffset.height)
            shadow.opacity = cachedShadowOpacity

            UIGraphicsBeginImageContext(shadow.bounds.size)
//            UIGraphicsBeginImageContextWithOptions(shadow.bounds.size, false, UIScreen.main.scale)
            let cxt = UIGraphicsGetCurrentContext()
            cxt?.translateBy(x: 0, y: shadow.bounds.height)
            cxt?.scaleBy(x: 1, y: -1)
            cxt?.draw(image, in: shadow.bounds.insetBy(dx: inset, dy: inset))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            let bezier = UIBezierPath.init(rect: shadow.bounds)
            bezier.append(UIBezierPath.init(rect: shadow.bounds
                .insetBy(dx: inset, dy: inset)
                .offsetBy(dx: -shadowOffset.width, dy: -shadowOffset.height)).reversing())

            let mask = CAShapeLayer()
            mask.path = bezier.cgPath

            shadow.contents = result?.sombraEffect(blurRadius: shadowRadius)?.cgImage
            shadow.mask = mask
        }
    }
}
