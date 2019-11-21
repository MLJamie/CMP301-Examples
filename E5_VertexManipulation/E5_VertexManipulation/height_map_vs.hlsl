//height map vertex shader


Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

cbuffer MatrixBuffer : register(b0)
{
	matrix worldMatrix;
	matrix viewMatrix;
	matrix projectionMatrix;
};
cbuffer TimeBuffer : register(b1)
{
	float time;
	float amplitude;
	float frequency;
	float speed;
}

struct InputType
{
	float4 position : POSITION;
	float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
};

struct OutputType
{
	float4 position : SV_POSITION;
	float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
};

float SampleHeightMap(float2 uv)
{
	const float scale = 1.0f;
	return scale * texture0.SampleLevel(sampler0, uv, 0.0f).r;
}

float3 Sobel(float2 tc)
{
	float height;
	float width;
	texture0.GetDimensions(width, height);
	float2 pxSz = float2(1.0f / width, 1.0f / height);

	float2 o00 = tc + float2(-pxSz.x, -pxSz.y);
	float2 o10 = tc + float2(0.0f, -pxSz.y);
	float2 o20 = tc + float2(pxSz.x, -pxSz.y);

	float2 o01 = tc + float2(-pxSz.x, 0.0f);
	float2 o21 = tc + float2(pxSz.x, 0.0f);

	float2 o02 = tc + float2(-pxSz.x, pxSz.y);
	float2 o12 = tc + float2(0.0f, pxSz.y);
	float2 o22 = tc + float2(pxSz.x, pxSz.y);

	float h00 = SampleHeightMap(o00);
	float h10 = SampleHeightMap(o10);
	float h20 = SampleHeightMap(o20);

	float h01 = SampleHeightMap(o01);
	float h21 = SampleHeightMap(o21);

	float h02 = SampleHeightMap(o02);
	float h12 = SampleHeightMap(o12);
	float h22 = SampleHeightMap(o22);

	float gX = h00 - h20 + 2.0f * h01 - 2.0f * h21 + h02 - h22;
	float gY = h00 + 2.0f * h10 + h20 - h02 - 2.0f * h12 - h22;

	float gZ = 0.001f * sqrt(max(0.0f, 1.0f - gX * gX - gY * gY));

	return normalize(float3(2.0f * gX, gZ, 2.0f * gY));
}


OutputType main(InputType input)
{
	OutputType output;



	float colors = texture0.SampleLevel(sampler0, input.tex, 0.0f);
	input.position.y = colors * 500;

	input.position.w = 1.0f;


	


	//generate normals using the sobel filter
	float3 normal = Sobel(input.tex);

	input.normal = normal;
	// Calculate the position of the vertex against the world, view, and projection matrices.
	output.position = mul(input.position, worldMatrix);
	output.position = mul(output.position, viewMatrix);
	output.position = mul(output.position, projectionMatrix);

	// Store the texture coordinates for the pixel shader.
	output.tex = input.tex;

	// Calculate the normal vector against the world matrix only and normalise.
	output.normal = mul(input.normal, (float3x3)worldMatrix);
	output.normal = normalize(output.normal);

	return output;
}
