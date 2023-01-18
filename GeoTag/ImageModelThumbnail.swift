//
//  ImageModelThumbnail.swift
//  GeoTag
//
//  Created by Marco S Hyman on 12/18/22.
//

import Foundation
import AppKit

extension ImageModel {

    /// Create an image thumbnail
    ///
    /// If image propertied can not be accessed or if needed properties
    /// do not exist the file is assumed to be a non-image file and a zero
    /// sized empty image is created.

    mutating func makeThumbnail() {
        // if a thumbail has already been created we're done
        guard thumbnail == nil else { return }

        var image = NSImage(size: NSMakeRect(0, 0, 0, 0).size)
        guard let imgRef = CGImageSourceCreateWithURL(fileURL as CFURL, nil) else {
            thumbnail = image
            return
        }
        
        // Create a "preview" of the image. If the image is larger than
        // 512x512 constrain the preview to that size.  512x512 is an
        // arbitrary limit.   Preview generation is used to work around a
        // performance hit when using large raw images
        let maxDimension = 512
        var imgOpts: [String: AnyObject] = [
            ImageModel.createThumbnailWithTransform : kCFBooleanTrue,
            ImageModel.createThumbnailFromImageIfAbsent : kCFBooleanTrue,
            ImageModel.thumbnailMaxPixelSize : maxDimension as AnyObject
        ]
        var checkSize = true
        repeat {
            if let imgPreview = CGImageSourceCreateThumbnailAtIndex(imgRef, 0, imgOpts as NSDictionary) {
                // Create an NSImage from the preview
                let imgHeight = CGFloat(imgPreview.height)
                let imgWidth = CGFloat(imgPreview.width)
                if imgOpts[ImageModel.createThumbnailFromImageAlways] == nil &&
                    imgHeight < 512 && imgWidth < 512 {
                    // thumbnail too small.   Build a larger thumbnail
                    imgOpts[ImageModel.createThumbnailFromImageIfAbsent] = nil
                    imgOpts[ImageModel.createThumbnailFromImageAlways] = kCFBooleanTrue
                    continue
                }
                let imgRect = NSMakeRect(0.0, 0.0, imgWidth, imgHeight)
                image = NSImage(size: imgRect.size)
                image.lockFocus()
                if let currentContext = NSGraphicsContext.current {
                    let context = currentContext.cgContext
                    context.draw(imgPreview, in: imgRect)
                }
                image.unlockFocus()
            }
            checkSize = false
        } while checkSize
        thumbnail = image
    }
}

// CFString to String casts for Image constants

extension ImageModel {
    static let createThumbnailWithTransform = kCGImageSourceCreateThumbnailWithTransform as String
    static let createThumbnailFromImageAlways = kCGImageSourceCreateThumbnailFromImageAlways as String
    static let createThumbnailFromImageIfAbsent = kCGImageSourceCreateThumbnailFromImageIfAbsent as String
    static let thumbnailMaxPixelSize = kCGImageSourceThumbnailMaxPixelSize as String
}