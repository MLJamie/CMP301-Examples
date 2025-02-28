
Texture2D shaderTexture : register(t0);
Texture2D depthMapTexture : register(t1);
Texture2D depthMapTexture2 : register(t2);

SamplerState diffuseSampler  : register(s0);
SamplerState shadowSampler : register(s1);

cbuffer LightBuffer : register(b0)
{
	float4 ambient[2];
	float4 diffuse[2];
	float3 direction[2];
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
    float4 lightViewPos[2] : TEXCOORD1;
};

// Calculate lighting intensity based on direction and normal. Combine with light colour.
float4 calculateLighting(float3 lightDirection, float3 normal, float4 diffuse)
{
    float intensity = saturate(dot(normal, lightDirection));
    float4 colour = saturate(diffuse * intensity);
    return colour;
}

float4 main(InputType input) : SV_TARGET
{
    float depthValue;
    float lightDepthValue;
    float shadowMapBias = 0.005f;
	float4 colours = float4(0.0f, 0.0f, 0.0f, 1.0f);
    float4 textureColour = shaderTexture.Sample(diffuseSampler, input.tex);


	for (int i = 0; i < 2; ++i)
	{
		float2 pTexCoord = input.lightViewPos[i].xy / input.lightViewPos[i].w;
		pTexCoord *= float2(0.5, -0.5);
		pTexCoord += float2(0.5f, 0.5f);

		// Determine if the projected coordinates are in the 0 to 1 range.  If not don't do lighting.
		if (pTexCoord.x < 0.f || pTexCoord.x > 1.f || pTexCoord.y < 0.f || pTexCoord.y > 1.f)
		{
			return textureColour;
		}

		// Sample the shadow map (get depth of geometry)
		if (i == 0)
		{
			depthValue = depthMapTexture.Sample(shadowSampler, pTexCoord).r;
		}
		else
		{
			depthValue = depthMapTexture2.Sample(shadowSampler, pTexCoord).r;
		}
		// Calculate the depth from the light.
		lightDepthValue = input.lightViewPos[i].z / input.lightViewPos[i].w;
		lightDepthValue -= shadowMapBias;

		// Compare the depth of the shadow map value and the depth of the light to determine whether to shadow or to light this pixel.
		if (lightDepthValue < depthValue)
		{
			colours += ambient[i] + calculateLighting(-direction[i], input.normal, diffuse[i]);
		}

	}
	//float4 colour = colours;
    //colour = saturate(colour + ambient[1]);
    return saturate(colours) * textureColour;
}