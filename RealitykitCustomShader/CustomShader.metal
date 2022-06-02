//
//  CustomShader.metal
//  RealitykitCustomShader
//
//  Created by Caner on 2022/6/2.
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

namespace {
    
    constexpr sampler repeatSampler(coord::normalized, address::repeat, filter::linear);
    
    float4 hash4(float2 p)
    {
        return fract(sin(float4(1.0 + dot(p, float2(37.0, 17.0)),
                               2.0 + dot(p, float2(11.0, 47.0)),
                               3.0 + dot(p, float2(41.0, 29.0)),
                               4.0 + dot(p, float2(23.0, 31.0))))*103.0);
    }
    
    float3 randomTiling(realitykit::texture::textures tex ,float2 uv)
    {
        float2 p = floor(uv);
        float2 f = fract(uv);
        
        float2 ddx = dfdx(uv);
        float2 ddy = dfdy(uv);
        
        float3 va = float3(0.0);
        float w1 = 0.0;
        float w2 = 0.0;
        
        for(int j=-1; j<=1; j++)
        {
            for(int i=-1; i<=1; i++)
            {
                float2 g = float2(float(i), float(j));
                float4 o = hash4(p+g);
                float2 r = g - f + o.xy;
                float d = dot(r, r);
                float w = exp(-5.0 * d);
                float3 c = float3(tex.base_color().sample(repeatSampler, (uv + o.zw), gradient2d(ddx, ddy)).rgb);
                
                va += w * c;
                w1 += w;
                w2 += w * w;
            }
        }
        
        return va/w1;
    }
}

[[visible]]
void surfaceShader(realitykit::surface_parameters params)
{
    auto tex = params.textures();
    auto surface = params.surface();
    auto material = params.material_constants();
    
    float2 uv = params.geometry().uv0();
    uv *= 3;
    
    half3 color = half3(randomTiling(tex, uv));
    //half3 color = tex.base_color().sample(repeatSampler, uv).rgb;
    
    color *= half3(material.base_color_tint());
    
    surface.set_base_color(color);
}

[[visible]]
void geometryModifier(realitykit::geometry_parameters params)
{
    auto uniforms = params.uniforms();
    float progress = uniforms.custom_parameter()[0];
    
    if(progress <= 0.0) {
        return;
    }
    
    auto vertexNormal = params.geometry().normal();
    
    params.geometry().set_model_position_offset((vertexNormal * progress * 3.0));
}
