#include "ColourTriangle.h"

// TriangleMesh.cpp
// Simple triangle mesh for example purposes. With texture cooridnates and normals.


// Initialise buffers and load texture.
ColourTriangle::ColourTriangle(ID3D11Device* device, ID3D11DeviceContext* deviceContext)
{
	initBuffers(device);
}


// Release resources.
ColourTriangle::~ColourTriangle()
{
	// Run parent deconstructor
	BaseMesh::~BaseMesh();
}

// Build shape and fill buffers.
void ColourTriangle::initBuffers(ID3D11Device* device)
{
	D3D11_SUBRESOURCE_DATA vertexData, indexData;

	vertexCount = 4;
	indexCount = 6;

	VertexType_Colour* vertices = new VertexType_Colour[vertexCount];
	unsigned long* indices = new unsigned long[indexCount];

	// Load the vertex array with data.
	vertices[0].position = XMFLOAT3(-1.0f, 1.0f, 0.0f);  // top left.
	vertices[0].colour = XMFLOAT4(0.0f, 1.0f, 0.0f, 1.0f);

	vertices[1].position = XMFLOAT3(-1.0f, -1.0f, 0.0f);  // bottom left.
	vertices[1].colour = XMFLOAT4(0.0f, 0.0f, 1.0f, 1.0f);

	vertices[2].position = XMFLOAT3(1.0f, -1.0f, 0.0f);  // bottom right.
	vertices[2].colour = XMFLOAT4(1.0f, 0.0f, 0.0f, 1.0f);

	vertices[3].position = XMFLOAT3(1.0f, 1.0f, 0.0f);  // top right.
	vertices[3].colour = XMFLOAT4(1.0f, 0.0f, 0.0f, 1.0f);





	// Load the index array with data.
	indices[0] = 1;  // bottom left
	indices[1] = 2;  // bottom right.
	indices[2] = 3;  // top right.

	indices[3] = 1;  // bottom left
	indices[4] = 3;  // top right
	indices[5] = 0;  // top left

	D3D11_BUFFER_DESC vertexBufferDesc = { sizeof(VertexType_Colour) * vertexCount, D3D11_USAGE_DEFAULT, D3D11_BIND_VERTEX_BUFFER, 0, 0, 0 };
	vertexData = { vertices, 0 , 0 };
	device->CreateBuffer(&vertexBufferDesc, &vertexData, &vertexBuffer);

	D3D11_BUFFER_DESC indexBufferDesc = { sizeof(unsigned long) * indexCount, D3D11_USAGE_DEFAULT, D3D11_BIND_INDEX_BUFFER, 0, 0, 0 };
	indexData = { indices, 0, 0 };
	device->CreateBuffer(&indexBufferDesc, &indexData, &indexBuffer);

	// Release the arrays now that the vertex and index buffers have been created and loaded.
	delete[] vertices;
	vertices = 0;
	delete[] indices;
	indices = 0;
}

void ColourTriangle::sendData(ID3D11DeviceContext* deviceContext, D3D_PRIMITIVE_TOPOLOGY top)
{
	unsigned int stride;
	unsigned int offset;

	// Set vertex buffer stride and offset.
	stride = sizeof(VertexType_Colour);
	offset = 0;

	deviceContext->IASetVertexBuffers(0, 1, &vertexBuffer, &stride, &offset);
	deviceContext->IASetIndexBuffer(indexBuffer, DXGI_FORMAT_R32_UINT, 0);
	deviceContext->IASetPrimitiveTopology(top);
}


