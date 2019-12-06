Texture2D shaderTexture : register(t0);
SamplerState sampler0 : register(s0);

cbuffer ScreenSizeBuffer : register(b0)
{
	float screenWidth;
	float screenHeight;
	float2 padding;
};

struct InputType
{
	float4 position : SV_POSITION;
	float2 tex : TEXCOORD0;
};

float4 main(InputType input) : SV_TARGET
{
	float4 colour;
	float radius = 7.0f;

	float3 mean[4] = { float3(0.0f, 0.0f, 0.0f), float3(0.0f, 0.0f, 0.0f), float3(0.0f, 0.0f, 0.0f), float3(0.0f, 0.0f, 0.0f) };
	
	float3 sigma[4] = { float3(0.0f, 0.0f, 0.0f), float3(0.0f, 0.0f, 0.0f), float3(0.0f, 0.0f, 0.0f), float3(0.0f, 0.0f, 0.0f) };

	float2 start[4] = { {-radius, -radius}, {-radius, 0}, {0, -radius}, {0, 0} };

	float2 pos;
	float3 col;
	float2 texelSize = float2(1.0f / screenWidth, 1.0f / screenHeight);
	for (int k = 0; k < 4; k++) 
	{
		for (int i = 0; i <= radius; i++) 
		{
			for (int j = 0; j <= radius; j++) 
			{
				pos = float2(i, j) + start[k];
				col = shaderTexture.Sample(sampler0, float4(input.tex + float2(pos.x * texelSize.x, pos.y * texelSize.y), 0., 0.)).xyz;
				mean[k] += col;
				sigma[k] += col * col;
			}
		}
	}
	
	float sigma2;

	float n = pow(radius + 1, 2);
	float4 color = shaderTexture.Sample(sampler0, input.tex);
	float min = 1;
	
	for (int l = 0; l < 4; l++) {
		mean[l] /= n;
		sigma[l] = abs(sigma[l] / n - mean[l] * mean[l]);
		sigma2 = sigma[l].x + sigma[l].y + sigma[l].z;
	
		if (sigma2 < min) {
			min = sigma2;
			color.xyz = mean[l].xyz;
		}
	}


	return colour;
}
