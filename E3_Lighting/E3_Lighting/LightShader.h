#pragma once

#include "DXF.h"

using namespace std;
using namespace DirectX;

class LightShader : public BaseShader
{
private:
	struct LightBufferType
	{
		XMFLOAT4 diffuse;
		XMFLOAT4 ambient;
		XMFLOAT3 position;
		float specularPower;
		XMFLOAT4 specularColour;
		
	};
	struct CameraBufferType
	{
		XMFLOAT3 position;
		float padding;
	};
public:
	LightShader(ID3D11Device* device, HWND hwnd);
	~LightShader();

	void setShaderParameters(ID3D11DeviceContext* deviceContext, const XMMATRIX &world, const XMMATRIX &view, const XMMATRIX &projection, ID3D11ShaderResourceView* texture, Light* light, FPCamera* cam);

private:
	void initShader(const wchar_t* cs, const wchar_t* ps);

private:
	ID3D11Buffer * matrixBuffer;
	ID3D11SamplerState* sampleState;
	ID3D11Buffer* lightBuffer;
	ID3D11Buffer* cameraBuffer;
};

