//
//  VisualEffect+variableBlur.swift
//  
//
//  Created by Dale Price on 11/18/23.
//

import SwiftUI

@available(iOS 17, macOS 14, macCatalyst 17, tvOS 17, visionOS 1, *)
internal let library = ShaderLibrary.bundle(Bundle.module)

@available(iOS 17, macOS 14, macCatalyst 17, tvOS 17, visionOS 1, *)
public extension VisualEffect {
	
	/// Applies a variable blur, with the blur radius at each pixel determined by a mask image. Requires a mask image that matches the size of the view's layer.
	///
	/// - Tip: Rather than using this effect directly, try ``SwiftUI/View/variableBlur(radius:maxSampleCount:maskRenderer:)`` which automatically handles creating a mask image of the correct size for you to draw into.
	///
	/// - Parameters:
	///   - radius: The maximum radial size of the blur in areas where the mask is fully opaque.
	///   - maxSampleCount: The maximum number of samples to take from the view's layer in each direction. Higher numbers produce a smoother, higher quality blur but are more GPU intensive. Values larger than `radius` have no effect.
	///   - mask: An image with an alpha channel to use as mask to determine the strength of the blur effect at each pixel. Fully transparent areas are unblurred; fully opaque areas are blurred by the full radius; partially transparent areas are blurred by the radius multiplied by the alpha value. The mask image should match the size of the view's layer.
	///   - maskSize: The size (resolution) of the mask image. Should match the size of the view the effect is applied to.
	///   - isEnabled: Whether the effect is enabled or not.
	/// - Returns: A new view that renders `self` with the blur shader applied as a layer effect.
	///
	/// - Important: Because this effect is based on SwiftUI's `layerEffect`, views backed by AppKit or UIKit views may not render. Instead, they log a warning and display a placeholder image to highlight the error.
	func variableBlur(
		radius: CGFloat,
		maxSampleCount: Int = 15,
		mask: Image,
		maskSize: CGSize,
		isEnabled: Bool = true
	) -> some VisualEffect {
		self.layerEffect(
			library.varBlurX(
				.float(radius),
				.float(CGFloat(maxSampleCount)),
				.image(mask),
				.float2(maskSize)
			),
			maxSampleOffset: CGSize(width: radius , height: radius),
			isEnabled: isEnabled
		)
		.layerEffect(
			library.varBlurY(
				.float(radius),
				.float(CGFloat(maxSampleCount)),
				.image(mask),
				.float2(maskSize)
			),
			maxSampleOffset: CGSize(width: radius, height: radius),
			isEnabled: isEnabled
		)
	}
}
