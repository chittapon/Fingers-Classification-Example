//
//  Extension.swift
//  FingersClassificationExample
//
//  Created by Chittapon Thongchim on 13/8/2562 BE.
//  Copyright © 2562 Appsynth. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func grayScaleData() -> Data {
        
        let imageRef = cgImage!
        let width = imageRef.width
        let height = imageRef.height
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bytesPerPixel = 1
        let bytesPerRow = bytesPerPixel * width
        let byteCount = bytesPerRow * height
        
        var bytes = [UInt8](repeating: 0, count: byteCount)
        let bitsPerComponent = 8
        
        guard let context = CGContext(data: &bytes,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.none.rawValue)
            
            else { fatalError("Can not convert to gray scale TT") }
        
        context.draw(imageRef, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return Data(copyingBufferOf: bytes.map { Float32($0) })
        
    }
    
}


extension Data {
    /// Creates a new buffer by copying the buffer pointer of the given array.
    ///
    /// - Warning: The given array's element type `T` must be trivial in that it can be copied bit
    ///     for bit with no indirection or reference-counting operations; otherwise, reinterpreting
    ///     data from the resulting buffer has undefined behavior.
    /// - Parameter array: An array with elements of type `T`.
    init<T>(copyingBufferOf array: [T]) {
        self = array.withUnsafeBufferPointer(Data.init)
    }
}

extension Array {
    /// Creates a new array from the bytes of the given unsafe data.
    ///
    /// - Warning: The array's `Element` type must be trivial in that it can be copied bit for bit
    ///     with no indirection or reference-counting operations; otherwise, copying the raw bytes in
    ///     the `unsafeData`'s buffer to a new array returns an unsafe copy.
    /// - Note: Returns `nil` if `unsafeData.count` is not a multiple of
    ///     `MemoryLayout<Element>.stride`.
    /// - Parameter unsafeData: The data containing the bytes to turn into an array.
    init?(unsafeData: Data) {
        guard unsafeData.count % MemoryLayout<Element>.stride == 0 else { return nil }
        #if swift(>=5.0)
        self = unsafeData.withUnsafeBytes { .init($0.bindMemory(to: Element.self)) }
        #else
        self = unsafeData.withUnsafeBytes {
            .init(UnsafeBufferPointer<Element>(
                start: $0,
                count: unsafeData.count / MemoryLayout<Element>.stride
            ))
        }
        #endif  // swift(>=5.0)
    }
}
