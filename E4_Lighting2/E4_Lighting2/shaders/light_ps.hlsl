// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)

Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

cbuffer LightBuffer : register(b0)
{
	float4 ambient[2];
	float4 diffuse[2];
	float4 position[2];
	float constantAtten;
	float linearAtten;
	float quadraticAtten;
	float padding;
};

struct InputType
{
	float4 position : SV_POSITION;
	float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
	float3 worldPosition : TEXCOORD1;
};

// Calculate lighting intensity based on direction and normal. Combine with light colour.
float4 calculateLighting(float3 lightDirection, float3 normal, float4 ldiffuse)
{
	float intensity = saturate(dot(normal, lightDirection));
	float4 colour = saturate(ldiffuse * intensity);
	return colour;
}

float4 main(InputType input) : SV_TARGET
{
	// Sample the texture. Calculate light intensity and colour, return light*texture for final pixel colour.
	float4 textureColour = texture0.Sample(sampler0, input.tex);
	float4 lightColours[2];
	for (int i = 0; i < 2; i++)
	{
		float3 distance = length(position[i] - input.worldPosition);
		float attenuation = 1 / (constantAtten + (linearAtten * distance) + (quadraticAtten * pow(distance, 2)));

		float3 lightVector = normalize(position[i] - input.worldPosition);

		lightColours[i] = ambient[i] + calculateLighting(lightVector, input.normal, (diffuse[i] * attenuation));

	}
	float4 lightColour = lightColours[0] + lightColours[1];
	return lightColour * textureColour;
}



