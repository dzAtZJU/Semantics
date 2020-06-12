//
//  Graphiccontent.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/9.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import UIKit

struct GraphicContent {
    func downsampleImage(at url: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOptions)!
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
            [kCGImageSourceShouldCacheImmediately: true,
             kCGImageSourceCreateThumbnailFromImageAlways: true,
             kCGImageSourceCreateThumbnailWithTransform: true,
             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }
}
