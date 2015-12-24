//
//  MedianFilter.metal
//  Sharpener
//
//  Created by Inti Guo on 12/23/15.
//  Copyright © 2015 Inti Guo. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct MedianFilterUniforms {
    float radius;
};

kernel void medianFilter(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         constant MedianFilterUniforms &uniforms [[buffer(0)]],
                         uint2 gid [[thread_position_in_grid]]) {
    int radius = uniforms.radius;
    float3 input = inTexture.read(gid).rgb;
    
    int size = radius * 2 + 1;
    float3 array[200];
    for (int i = 0; i <= size; i++) {
        for (int j = 0; j <= size; j++) {
            uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
            float3 current = inTexture.read(textureIndex).rgb;
            array[i*size + j] = current.rgb;
        }
    }
    
    for (int i = 0; i <= size; i++) {
        for (int j = 0; j <= size-1; j++) {
            float3 temp = array[i*size + j];
            float factor = step(array[i*size + j].g, array[i*size + j + 1].g);
            array[i*size + j] = mix(array[i*size + j], array[i*size + j + 1], factor);
            array[i*size + j + 1] = mix(temp, array[i*size + j + 1], 1-factor);
        }
    }
    
    input = array[size*size/2].rgb;
    outTexture.write(float4(input, 1.0), gid);
}


