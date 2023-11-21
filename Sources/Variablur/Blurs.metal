#include <metal_stdlib>
using namespace metal;

#include <SwiftUI/SwiftUI_Metal.h>

// Formula of a gaussian function as described by https://en.wikipedia.org/wiki/Gaussian_blur
inline half gaussianKernel1D(half x, half sigma) {
	const half gaussianExponent = -(x * x) / (2.0h * sigma * sigma);
	return (1.0h / (2.0h * M_PI_H * sigma * sigma)) * exp(gaussianExponent);
}

// Calculate blurred pixel value using the weighted average of multiple samples along the X axis
half4 gaussianBlurX(float2 pos, SwiftUI::Layer layer, half radius, half maxSamples) {
	const half interval = max(1.0h, radius / maxSamples);

	// take the first sample
	const half weight = gaussianKernel1D(0.0h, radius / 2.0h);
	half4 total = layer.sample(pos) * weight;
	half count = weight;
	
	// if the radius is high enough to take more samples, take them
	if(interval <= radius) {
		for (half distance = interval; distance <= radius; distance += interval) {
			const half weight = gaussianKernel1D(distance, radius / 2.0h);
			count += weight * 2.0h;
			total += layer.sample(float2(half(pos.x) - distance, pos.y)) * weight;
			total += layer.sample(float2(half(pos.x) + distance, pos.y)) * weight;
		}
	}
	
	// return the weighted average of all samples
	return total / count;
}

// Calculate blurred pixel value using the weighted average of multiple samples along the Y axis
half4 gaussianBlurY(float2 pos, SwiftUI::Layer layer, half radius, half maxSamples) {
	const half interval = max(1.0h, radius / maxSamples);
	
	// take the first sample
	const half weight = gaussianKernel1D(0.0h, radius / 2.0h);
	half4 total = layer.sample(pos) * weight;
	half count = weight;
	
	// if the radius is high enough to take more samples, take them
	if(interval <= radius) {
		for (half distance = interval; distance <= radius; distance += interval) {
			const half weight = gaussianKernel1D(distance, radius / 2.0h);
			count += weight * 2.0h;
			total += layer.sample(float2(pos.x, half(pos.y) - distance)) * weight;
			total += layer.sample(float2(pos.x, half(pos.y) + distance)) * weight;
		}
	}
	
	// return the weighted average of all samples
	return total / count;
}

// Variable blur effect along the X axis that samples from a texture to determine the blur radius multiplier
[[ stitchable ]] half4 varBlurX(float2 pos, SwiftUI::Layer layer, float radius, float maxSamples, texture2d<half> mask, float2 size) {
	// sample the mask at the current position
	const half4 maskSample = mask.sample(metal::sampler(metal::filter::linear), pos / size);
	// determine the blur radius at this pixel based on the sample's alpha
	const half pixelRadius = maskSample.a * half(radius);
	// apply the blur if the effective radius is nonzero
	if(pixelRadius >= 1) {
		return gaussianBlurX(pos, layer, pixelRadius, maxSamples);
	} else {
		return layer.sample(pos);
	}
}

// Variable blur effect along the Y axis that samples from a texture to determine the blur radius multiplier
[[ stitchable ]] half4 varBlurY(float2 pos, SwiftUI::Layer layer, float radius, float maxSamples, texture2d<half> mask, float2 size) {
	// sample the mask at the current position
	const half4 maskSample = mask.sample(metal::sampler(metal::filter::linear), pos / size);
	// determine the blur radius at this pixel based on the sample's alpha
	const half pixelRadius = maskSample.a * half(radius);
	// apply the blur if the effective radius is nonzero
	if(pixelRadius >= 1) {
		return gaussianBlurY(pos, layer, pixelRadius, maxSamples);
	} else {
		return layer.sample(pos);
	}
}
