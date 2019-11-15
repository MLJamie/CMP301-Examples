// Light vertex shader
// Standard issue vertex shader, apply matrices, pass info to pixel shader


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

OutputType main(InputType input)
{
	OutputType output;
	float spd = time * speed;
	//offset position based off sine wave
	input.position.y = (amplitude * sin((input.position.x * frequency) + (spd))) + (amplitude * cos((input.position.z * frequency) + (spd)));


	//normals
	float3 pointNorth, pointEast, pointSouth, pointWest, vectorNorth, vectorEast, vectorSouth, vectorWest, normalSW, normalSE, normalNE, normalNW, finalNormal;


	//fix the normals

	pointNorth.x = input.position.x;
	pointNorth.z = input.position.z + 1;
	pointNorth.y = amplitude * sin((pointNorth.x * frequency) + time * speed) + amplitude * cos((pointNorth.z * frequency) + time * speed);
	
	pointEast.x = input.position.x + 1;
	pointEast.z = input.position.z;
	pointEast.y = amplitude * sin((pointEast.x * frequency) + time * speed) + amplitude * cos((pointEast.z * frequency) + time * speed);

	pointSouth.x = input.position.x;
	pointSouth.z = input.position.z - 1;
	pointSouth.y = amplitude * sin((pointSouth.x * frequency) + time * speed) + amplitude * cos((pointSouth.z * frequency) + time * speed);

	pointWest.x = input.position.x - 1;
	pointWest.z = input.position.z;
	pointWest.y = amplitude * sin((pointWest.x * frequency) + time * speed) + amplitude * cos((pointWest.z * frequency) + time * speed);

	vectorNorth = normalize(pointNorth - input.position);
	vectorEast = normalize(pointEast - input.position);
	vectorSouth = normalize(pointSouth - input.position);
	vectorWest = normalize(pointWest - input.position);
	
	
	normalNE = cross(vectorNorth, vectorEast);
	normalNW = cross(vectorNorth, vectorWest);
	normalSW = cross(vectorSouth, vectorWest);
	normalSE = cross(vectorEast, vectorSouth);
	

	finalNormal = (normalSW + normalSE + normalNW + normalNE) / 4;

	input.normal.x = finalNormal.x;
	input.normal.y = finalNormal.y;
	input.normal.z = finalNormal.z;


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