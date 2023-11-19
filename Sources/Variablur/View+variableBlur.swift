//
//  File.swift
//  
//
//  Created by Dale Price on 11/18/23.
//

import SwiftUI

public extension View {
	func variableBlur(
		radius: CGFloat,
		quality: CGFloat = 1,
		gradientRenderer: @escaping (CGSize, inout GraphicsContext) -> Void
	) -> some View {
		self.visualEffect { content, geometryProxy in
			content.variableBlur(
				radius: radius,
				quality: quality,
				gradient: Image(size: geometryProxy.size, renderer: { context in
					gradientRenderer(geometryProxy.size, &context)
				}),
				gradientSize: geometryProxy.size
			)
		}
	}
}

#Preview("Image") {
	Image(systemName: "figure.walk.circle")
		.font(.system(size: 300))
		.variableBlur(radius: 30) { size, context in
			context.fill(
				Path(CGRect(origin: .zero, size: size)),
				with: .linearGradient(
					.init(colors: [.white, .clear]),
					startPoint: .zero,
					endPoint: .init(x: 0, y: size.height)
				)
			)
		}
}

#Preview("Image background blur behind UI") {
	VStack(alignment: .leading) {
		Spacer()
			.frame(maxWidth: .infinity)
		Text("Jazzy Squiggle")
			.font(.headline)
		Text("You can read this content because the squiggle is blurred behind it.")
			.font(.subheadline)
		HStack {
			Button { } label: {
				Text("Do Something")
			}
			Button { } label: {
				Text("Do Something Else")
			}
		}
		Spacer()
		Text("Plot twist: nothing really happens when you press these buttons.")
			.font(.caption2)
			.foregroundStyle(.secondary)
	}
	.frame(width: 300, height: 300)
	.scenePadding()
	.background {
		Image(systemName: "scribble.variable")
			.foregroundStyle(Color.cyan)
			.font(.system(size: 300))
			.variableBlur(radius: 40) { size, context in
				context.fill(
					Path(CGRect(origin: .zero, size: size)),
					with: .linearGradient(
						.init(colors: [.clear, .white]),
						startPoint: .init(x: 0, y: 150),
						endPoint: .init(x: 0, y: size.height)
					)
				)
			}
	}
}
