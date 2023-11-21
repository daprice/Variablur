//
//  File.swift
//  
//
//  Created by Dale Price on 11/18/23.
//

import SwiftUI

@available(iOS 17, macOS 14, macCatalyst 17, tvOS 17, visionOS 1, *)
public extension View {
	
	/// Applies a variable blur to the view, with the blur radius at each pixel determined by a mask that you create.
	/// 
	/// - Parameters:
	///   - radius: The radial size of the blur in areas where the mask is fully opaque.
	///   - maxSampleCount: The maximum number of samples the shader may take from the view's layer in each direction. Higher numbers produce a smoother, higher quality blur but are more GPU intensive. Values larger than `radius` have no effect. The default of 15 provides balanced results but may cause banding on some images at larger blur radii.
	///   - maskRenderer: A rendering closure to draw the mask used to determine the intensity of the blur at each pixel. The closure receives a `GeometryProxy` with the view's layout information, and a `GraphicsContext` to draw into.
	/// - Returns: The view with the variable blur effect applied.
	///
	/// The strength of the blur effect at any point on the view is determined by the transparency of the mask at that point. Areas where the mask is fully opaque are blurred by the full radius; areas where the mask is partially transparent are blurred by a proportionally smaller radius. Areas where the mask is fully transparent are left unblurred.
	///
	/// - Tip: To achieve a progressive blur or gradient blur, draw a gradient from transparent to opaque in your mask image where you want the transition from clear to blurred to take place.
	///
	/// - Important: Because this effect is implemented as a SwiftUI `layerEffect`, it is subject to the same limitations. Namely, views backed by AppKit or UIKit views may not render. Instead, they log a warning and display a placeholder image to highlight the error.
	func variableBlur(
		radius: CGFloat,
		maxSampleCount: Int = 15,
		maskRenderer: @escaping (GeometryProxy, inout GraphicsContext) -> Void
	) -> some View {
		self.visualEffect { content, geometryProxy in
			content.variableBlur(
				radius: radius,
				maxSampleCount: maxSampleCount,
				mask: Image(size: geometryProxy.size, renderer: { context in
					maskRenderer(geometryProxy, &context)
				}),
				maskSize: geometryProxy.size
			)
		}
	}
}

#Preview("Image with progressive blur") {
	Image(systemName: "figure.walk.circle")
		.font(.system(size: 300))
		.variableBlur(radius: 30) { geometryProxy, context in
			// draw a linear gradient across the entire mask from top to bottom
			context.fill(
				Path(geometryProxy.frame(in: .local)),
				with: .linearGradient(
					.init(colors: [.white, .clear]),
					startPoint: .zero,
					endPoint: .init(x: 0, y: geometryProxy.size.height)
				)
			)
		}
}

#Preview("Vignette") {
	Image(systemName: "rectangle.checkered")
		.font(.system(size: 300))
		.variableBlur(radius: 100) { geometryProxy, context in
			// Add a blur to the mask to create the vignette effect
			context.addFilter(
				.blur(radius: 45)
			)
			
			// Mask off an ellipse centered on the view, where we don't want the variable blur applied
			context.clip(
				to: Path(
					ellipseIn: geometryProxy.frame(in: .local).insetBy(dx: 10, dy: 10)
				), options: .inverse
			)
			
			// Fill the entire context *except* the masked shape with an opaque color
			context.fill(
				Path(geometryProxy.frame(in: .local)),
				with: .color(.white)
			)
		}
}

#Preview("Blur masked using a shape") {
	Image(systemName: "circle.hexagongrid")
		.font(.system(size: 300))
		.variableBlur(radius: 30) { geometryProxy, context in
			// draw a shape in an opaque color to apply the variable blur within the shape
			context.fill(
				Path(
					roundedRect: CGRect(
						origin: .init(
							x: geometryProxy.size.width / 5,
							y: geometryProxy.size.height / 4
						),
						size: .init(
							width: geometryProxy.size.width / 5 * 3,
							height: geometryProxy.size.height / 4 * 2
						)
					), cornerRadius: 40
				),
				with: .color(.white)
			)
		}
}

#Preview("Blur excluding a mask shape") {
	Image(systemName: "circle.hexagongrid")
		.font(.system(size: 300))
		.variableBlur(radius: 30) { geometryProxy, context in
			// Mask off a rounded rectangle where we don't want the blur applied
			context.clip(
				to: Path(
					roundedRect: CGRect(
						origin: .init(
							x: geometryProxy.size.width / 5,
							y: geometryProxy.size.height / 4
						),
						size: .init(
							width: geometryProxy.size.width / 5 * 3,
							height: geometryProxy.size.height / 4 * 2
						)
					), cornerRadius: 40
				), options: .inverse
			)
			
			// Fill the entire context *except* the masked shape with an opaque color
			context.fill(
				Path(geometryProxy.frame(in: .local)),
				with: .color(.white)
			)
		}
}

#Preview("Variable blur around a mask shape") {
	Image(systemName: "circle.hexagongrid")
		.font(.system(size: 300))
		.variableBlur(radius: 30) { geometryProxy, context in
			// blur what we draw to the mask so that the final effect fades around the masked shape
			context.addFilter(.blur(radius: 30))
			
			// draw a blurred rounded rectangle to the mask
			context.fill(
				Path(
					roundedRect: CGRect(
						origin: .init(
							x: geometryProxy.size.width / 5,
							y: geometryProxy.size.height / 4
						),
						size: .init(
							width: geometryProxy.size.width / 5 * 3,
							height: geometryProxy.size.height / 4 * 2
						)
					), cornerRadius: 40
				),
				with: .color(.white)
			)
		}
}

#Preview("Blurred background behind UI") {
	VStack(alignment: .center) {
		Spacer()
			.frame(maxWidth: .infinity)
		Text("Jazzy Squiggle")
			.font(.headline)
		Text("You can read this content because the squiggle is blurred behind it.")
			.font(.subheadline)
		HStack {
			Button { } label: {
				Text("Like")
			}
			Button { } label: {
				Text("Subscribe")
			}
		}
		Text("Plot twist: nothing really happens when you press these buttons.")
			.font(.caption2)
			.foregroundStyle(.secondary)
	}
	.buttonStyle(.bordered)
	.multilineTextAlignment(.center)
	.environment(\.backgroundMaterial, .thin) // this allows the buttons to take on their overlay appearance which looks good over the variable blur
	.scenePadding()
	.frame(width: 300, height: 300)
	.background {
		Image(systemName: "scribble.variable")
			.foregroundStyle(Color.cyan)
			.font(.system(size: 300))
			.variableBlur(radius: 40) { geometryProxy, context in
				context.fill(
					Path(CGRect(origin: .zero, size: geometryProxy.size)),
					with: .linearGradient(
						.init(colors: [.clear, .white]),
						startPoint: .init(x: 0, y: 150),
						endPoint: .init(x: 0, y: geometryProxy.size.height)
					)
				)
			}
	}
}
