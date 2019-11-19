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

	float gZ = 0.01f * sqrt(max(0.0f, 1.0f - gX * gX - gY * gY));

	return normalize(float3(2.0f * gX, gZ, 2.0f * gY));
}


OutputType main(InputType input)
{
	OutputType output;



	float colors = texture0.SampleLevel(sampler0, input.tex, 0.0f);
	input.position.y = colors * 50;

	input.position.w = 1.0f;


	


	//normals
	//float3 pointNorth, pointEast, pointSouth, pointWest, vectorNorth, vectorEast, vectorSouth, vectorWest, normalSW, normalSE, normalNE, normalNW, finalNormal;


	////fix the normals

	//pointNorth.x = input.position.x;
	//pointNorth.z = input.position.z + 1;
	//pointNorth.y = texture0.SampleLevel(sampler0, float2(input.tex.x, input.tex.y - 1), 0.0f);

	//pointEast.x = input.position.x + 1;
	//pointEast.z = input.position.z;
	//pointEast.y = texture0.SampleLevel(sampler0, float2(input.tex.x + 1, input.tex.y), 0.0f);

	//pointSouth.x = input.position.x;
	//pointSouth.z = input.position.z - 1;
	//pointSouth.y = texture0.SampleLevel(sampler0, float2(input.tex.x, input.tex.y + 1), 0.0f);

	//pointWest.x = input.position.x - 1;
	//pointWest.z = input.position.z;
	//pointWest.y = texture0.SampleLevel(sampler0, float2(input.tex.x - 1, input.tex.y), 0.0f);

	//vectorNorth = normalize(pointNorth - input.position);
	//vectorEast = normalize(pointEast - input.position);
	//vectorSouth = normalize(pointSouth - input.position);
	//vectorWest = normalize(pointWest - input.position);


	//normalNE = cross(vectorNorth, vectorEast);
	//normalNW = cross(vectorNorth, vectorWest);
	//normalSW = cross(vectorSouth, vectorWest);
	//normalSE = cross(vectorEast, vectorSouth);


	//finalNormal = (normalSW + normalSE + normalNW + normalNE) / 4;

	//input.normal.x = finalNormal.x;
	//input.normal.y = finalNormal.y;
	//input.normal.z = finalNormal.z;
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
