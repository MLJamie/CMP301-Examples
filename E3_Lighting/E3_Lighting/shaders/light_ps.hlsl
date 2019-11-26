// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)

Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

cbuffer LightBuffer : register(b0)
{
	float4 diffuseColour;
	float4 ambientColour;
	float3 lightPosition;
	float specularPower;
	float4 specularColour;
	
};

struct InputType
{
	float4 position : SV_POSITION;
	float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
	float3 viewVector : TEXCOORD1;
	float3 worldPosition : TEXCOORD2;
	
};

float4 calcSpecular(float3 lightDirection, float3 normal, float3 viewVector, float4 specularColour, float4 specularPower)
{
	// blinn-phong specular calculation
	float3 halfway = normalize(lightDirection + viewVector);
	float specularIntensity = pow(max(dot(normal, halfway), 0.0), specularPower);
	return saturate(specularColour * specularIntensity);
}

// Calculate lighting intensity based on direction and normal. Combine with light colour.
float4 calculateLighting(float3 lightDirection, float3 normal, float4 diffuse)
{
	float intensity = saturate(dot(normal, lightDirection));
	float4 colour = saturate(diffuse * intensity);
	return colour + ambientColour;
}

float4 main(InputType input) : SV_TARGET
{
	float4 textureColour;
	float4 lightColour;

	// Sample the texture. Calculate light intensity and colour, return light*texture for final pixel colour.
	textureColour = texture0.Sample(sampler0, input.tex);
	float3 lightVector = normalize(lightPosition - input.worldPosition);
	lightColour = calculateLighting(lightVector, input.normal, diffuseColour);
	
	return (lightColour * textureColour) + calcSpecular(lightVector, input.normal, input.viewVector, specularColour, specularPower);
}



