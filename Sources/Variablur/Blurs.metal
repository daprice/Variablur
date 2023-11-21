#include <metal_stdlib>
using namespace metal;

#include <SwiftUI/SwiftUI_Metal.h>

constant half M_PI_H_HALVED = M_PI_H / 2.0h;

half4 smoothBlurX(float2 pos, SwiftUI::Layer layer, float radius, float quality) {
	half4 total = half4(0.0h, 0.0h, 0.0h, 0.0h);
	half count = 0.0h;
	
	half maxX = pos.x + radius;
	half interval = max(1.0h, half(radius) / 10.0h) * (1.0h / max(0.1h, min(1.0h, half(quality))));
	for(half x = pos.x - radius; x <= maxX; x += interval) {
		half weight = cos(((x - half(pos.x)) / half(radius)) * M_PI_H_HALVED); // TODO: make this a proper gaussian curve and move it to its own function
		total += layer.sample(float2(x, pos.y)) * weight;
		count += weight;
	}
	
	return total / count;
}

half4 smoothBlurY(float2 pos, SwiftUI::Layer layer, float radius, float quality) {
	half4 total = half4(0.0h, 0.0h, 0.0h, 0.0h);
	half count = 0.0h;
	
	half maxY = pos.y + radius;
	half interval = max(1.0h, half(radius) / 10.0h) * (1.0h / max(0.1h, min(1.0h, half(quality))));
	for(half y = pos.y - radius; y <= maxY; y += interval) {
		half weight = cos(((y - half(pos.y)) / half(radius)) * M_PI_H_HALVED);
		total += layer.sample(float2(pos.x, y)) * weight;
		count += weight;
	}
	
	return total / count;
}

[[ stitchable ]] half4 varBlurX(float2 pos, SwiftUI::Layer layer, float radius, float quality, texture2d<half> gradient, float2 size) {
	half4 gradientSample = gradient.sample(metal::sampler(metal::filter::linear), pos / size);
	float pixelRadius = gradientSample.a * radius;
	if(pixelRadius >= 1) {
		return smoothBlurX(pos, layer, pixelRadius, quality);
	} else {
		return layer.sample(pos);
	}
}

[[ stitchable ]] half4 varBlurY(float2 pos, SwiftUI::Layer layer, float radius, float quality, texture2d<half> gradient, float2 size) {
	half4 gradientSample = gradient.sample(metal::sampler(metal::filter::linear), pos / size);
	float pixelRadius = gradientSample.a * radius;
	if(pixelRadius >= 1) {
		return smoothBlurY(pos, layer, pixelRadius, quality);
	} else {
		return layer.sample(pos);
	}
}
