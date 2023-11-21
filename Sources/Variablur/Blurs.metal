#include <metal_stdlib>
using namespace metal;

#include <SwiftUI/SwiftUI_Metal.h>

// Formula of a gaussian function as described by https://en.wikipedia.org/wiki/Gaussian_blur
inline half gaussianKernel1D(half x, half sigma) {
	const half gaussianExponent = -(x * x) / (2.0h * sigma * sigma);
	return (1.0h / (2.0h * M_PI_H * sigma * sigma)) * exp(gaussianExponent);
}

// Calculate blurred pixel value using the weighted average of multiple samples along the X axis
half4 smoothBlurX(float2 pos, SwiftUI::Layer layer, float radius, float quality) {
	half4 total = half4(0.0h, 0.0h, 0.0h, 0.0h);
	half count = 0.0h;
	
	const half maxX = pos.x + radius;
	const half interval = max(1.0h, half(radius) / 10.0h) * (1.0h / max(0.1h, min(1.0h, half(quality))));
	for(half x = pos.x - radius; x <= maxX; x += interval) {
		const half weight = gaussianKernel1D(x - half(pos.x), half(radius)/2.0h);
		total += layer.sample(float2(x, pos.y)) * weight;
		count += weight;
	}
	
	return total / count;
}

// Calculate blurred pixel value using the weighted average of multiple samples along the Y axis
half4 smoothBlurY(float2 pos, SwiftUI::Layer layer, float radius, float quality) {
	half4 total = half4(0.0h, 0.0h, 0.0h, 0.0h);
	half count = 0.0h;
	
	const half maxY = pos.y + radius;
	const half interval = max(1.0h, half(radius) / 10.0h) * (1.0h / max(0.1h, min(1.0h, half(quality))));
	for(half y = pos.y - radius; y <= maxY; y += interval) {
		const half weight = gaussianKernel1D(y - half(pos.y), half(radius)/2.0h);
		total += layer.sample(float2(pos.x, y)) * weight;
		count += weight;
	}
	
	return total / count;
}

// Variable blur effect along the X axis that samples from a texture to determine the blur radius multiplier
[[ stitchable ]] half4 varBlurX(float2 pos, SwiftUI::Layer layer, float radius, float quality, texture2d<half> mask, float2 size) {
	// sample the mask at the current position
	const half4 maskSample = mask.sample(metal::sampler(metal::filter::linear), pos / size);
	// determine the blur radius at this pixel based on the sample's alpha
	const float pixelRadius = maskSample.a * radius;
	// apply the blur if the effective radius is nonzero
	if(pixelRadius >= 1) {
		return smoothBlurX(pos, layer, pixelRadius, quality);
	} else {
		return layer.sample(pos);
	}
}

// Variable blur effect along the Y axis that samples from a texture to determine the blur radius multiplier
[[ stitchable ]] half4 varBlurY(float2 pos, SwiftUI::Layer layer, float radius, float quality, texture2d<half> mask, float2 size) {
	// sample the mask at the current position
	const half4 maskSample = mask.sample(metal::sampler(metal::filter::linear), pos / size);
	// determine the blur radius at this pixel based on the sample's alpha
	const float pixelRadius = maskSample.a * radius;
	// apply the blur if the effective radius is nonzero
	if(pixelRadius >= 1) {
		return smoothBlurY(pos, layer, pixelRadius, quality);
	} else {
		return layer.sample(pos);
	}
}
