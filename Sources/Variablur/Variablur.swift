import SwiftUI

fileprivate let library = ShaderLibrary.bundle(Bundle.module)

public struct BlurView: View {
	public var body: some View {
		Image(systemName: "figure.walk.circle")
			.resizable()
			.frame(maxWidth: 300, maxHeight: 300)
			.font(.system(size: 300))
			.foregroundStyle(Color(red: 0, green: 0, blue: 0.5))
			.visualEffect { content, geometryProxy in
				content
					.layerEffect(library.varBlurX(
						.float(20),
						.float(1),
						.image(Image(size: .init(width: geometryProxy.size.width, height: geometryProxy.size.height)) { context in
							context.fill(
								Path( CGRect(origin: .init(x: 0, y: 0), size: geometryProxy.size)),
								with: .linearGradient(.init(colors: [.white, .clear]), startPoint: .zero, endPoint: .init(x: 0, y: geometryProxy.size.height))
							)
						}),
						.float2(geometryProxy.size)
					), maxSampleOffset: .init(width: 20, height: 20))
					.layerEffect(library.varBlurY(
						.float(20),
						.float(1),
						.image(Image(size: .init(width: geometryProxy.size.width, height: geometryProxy.size.height)) { context in
							context.fill(
								Path( CGRect(origin: .init(x: 0, y: 0), size: geometryProxy.size)),
								with: .linearGradient(.init(colors: [.white, .clear]), startPoint: .zero, endPoint: .init(x: 0, y: geometryProxy.size.height))
							)
						}),
						.float2(geometryProxy.size)
					), maxSampleOffset: .init(width: 20, height: 20))
			}
	}
}

#Preview {
	BlurView()
}
