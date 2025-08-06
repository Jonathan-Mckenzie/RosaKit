//
//  ArrayDoubleExtensions.swift
//  RosaKit
//
//  Created by Hrebeniuk Dmytro on 17.12.2019.
//  Copyright © 2019 Dmytro Hrebeniuk. All rights reserved.
//

import Foundation

extension Array where Iterator.Element: FloatingPoint {
        
    func floatingPointStrided(shape: (width: Int, height: Int), stride: (xStride: Int, yStride: Int)? = nil) -> [[Element]] {
        var resultArray: [[Element]] = []
        
        let byteStrideX = stride?.xStride ?? 1
        let byteStrideY = stride?.yStride ?? shape.height
        var byteOffsetX: Int = 0
        var byteOffsetY: Int = 0
        for yIndex in 0..<shape.width {
            var lineArray = [Element]()
            for xIndex in 0..<shape.height {
                let value = self[(yIndex+xIndex)%self.count]
                
                lineArray.append(value)
            }
            resultArray.append(lineArray)
        }
        
        return resultArray
    }
    
    func strided(shape: (width: Int, height: Int), stride: (xStride: Int, yStride: Int)? = nil) -> [[Element]] {
        let elementSize = MemoryLayout<Element>.size
        return floatingPointStrided(shape: shape, stride: (xStride: (stride?.xStride ?? elementSize)/elementSize, yStride:  (stride?.yStride ?? elementSize)/elementSize))
    }
    
    var diff: [Element] {
        var diff = [Element]()
        
        for index in 1..<self.count {
            let value = self[index]-self[index-1]
            diff.append(value)
        }
        
        return diff
    }
    
    func outerSubstract(array: [Element]) -> [[Element]] {
        var result = [[Element]]()
        
        let rows = self.count
        let cols = array.count
        
        for row in 0..<rows {
            var rowValues = [Element]()
            for col in 0..<cols {
                let value = self[row] - array[col]
                rowValues.append(value)
            }
            
            result.append(rowValues)
        }
        
        return result
    }
    
}

extension Array where Iterator.Element == Double {
        
    func frame(frameLength: Int = 2048, hopLength: Int = 512) -> [[Element]] {
        let framesCount = Swift.max(0, 1 + (count - frameLength) / hopLength)
        guard framesCount > 0, frameLength > 0, hopLength > 0 else { return [] }
        
        var result = [[Element]](repeating: [Element](repeating: Element.zero, count: frameLength), count: framesCount)
        
        for frameIndex in 0..<framesCount {
            let start = frameIndex * hopLength
            let end = Swift.min(start + frameLength, count)
            result[frameIndex] = Array(self[start..<end])
            // Pad with zeros if needed
            if end - start < frameLength {
                result[frameIndex].append(contentsOf: [Element](repeating: Element.zero, count: frameLength - (end - start)))
            }
        }
        
        return result.transposed
    }
                                       
}
