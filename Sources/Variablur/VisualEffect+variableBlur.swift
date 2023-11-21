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
	
	/// Applies a variable blur, with the blur radius at each pixel determined by a mask image.
	/// - Parameters:
	///   - radius: The maximum radial size of the blur in areas where the mask is fully opaque.
	///   - quality: The ratio of samples to take when computing each pixel. Recommended values are 1 for full quality, or 0.5 for half quality (less GPU-intensive but produces a somewhat blocky blur).
	///   - mask: An image with an alpha channel to use as mask to determine the strength of the blur effect at each pixel. Fully transparent areas are unblurred; fully opaque areas are blurred by the full radius; partially transparent areas are blurred by the radius multiplied by the alpha value.
	///   - maskSize: The size (resolution) of the mask image. Should match the size of the view the effect is applied to.
	///   - isEnabled: Whether the effect is enabled or not.
	/// - Returns: A new view that renders `self` with the blur shader applied as a layer effect.
	///
	/// - Important: Because this effect is based on SwiftUI's `layerEffect`, views backed by AppKit or UIKit views may not render. Instead, they log a warning and display a placeholder image to highlight the error.
	func variableBlur(
		radius: CGFloat,
		quality: CGFloat = 1,
		mask: Image,
		maskSize: CGSize,
		isEnabled: Bool = true
	) -> some VisualEffect {
		self.layerEffect(
			library.varBlurX(
				.float(radius),
				.float(quality),
				.image(mask),
				.float2(maskSize)
			),
			maxSampleOffset: CGSize(width: radius , height: radius),
			isEnabled: isEnabled
		)
		.layerEffect(
			library.varBlurY(
				.float(radius),
				.float(quality),
				.image(mask),
				.float2(maskSize)
			),
			maxSampleOffset: CGSize(width: radius, height: radius),
			isEnabled: isEnabled
		)
	}
}
