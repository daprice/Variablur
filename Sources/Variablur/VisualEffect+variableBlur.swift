//
//  File.swift
//  
//
//  Created by Dale Price on 11/18/23.
//

import SwiftUI

internal let library = ShaderLibrary.bundle(Bundle.module)

public extension VisualEffect {
	func variableBlur(
		radius: CGFloat,
		quality: CGFloat = 1,
		gradient: Image,
		gradientSize: CGSize,
		isEnabled: Bool = true
	) -> some VisualEffect {
		self.layerEffect(
			library.varBlurX(
				.float(radius),
				.float(quality),
				.image(gradient),
				.float2(gradientSize)
			),
			maxSampleOffset: CGSize(width: radius, height: radius),
			isEnabled: isEnabled
		)
		.layerEffect(
			library.varBlurY(
				.float(radius),
				.float(quality),
				.image(gradient),
				.float2(gradientSize)
			),
			maxSampleOffset: CGSize(width: radius, height: radius),
			isEnabled: isEnabled
		)
	}
}
