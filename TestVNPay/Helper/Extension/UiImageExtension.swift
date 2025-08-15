//
//  UiImageExtension.swift
//  TestVNPay
//
//  Created by HoangDucAnh on 13/8/25.
//

import Foundation
import UIKit

extension UIImage {
    func decodedImage() -> UIImage {
            guard let cgImage = self.cgImage else { return self }
            let size = CGSize(width: cgImage.width, height: cgImage.height)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: 0,
                                    space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
            guard let drawnImage = context?.makeImage() else { return self }
            return UIImage(cgImage: drawnImage)
        }
        
        func resized(to targetSize: CGSize) -> UIImage {
            let format = UIGraphicsImageRendererFormat()
            format.scale = UIScreen.main.scale
            let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
            return renderer.image { _ in
                self.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }
}
