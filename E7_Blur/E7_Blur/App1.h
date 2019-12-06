// Application.h
#ifndef _APP1_H
#define _APP1_H

// Includes
#include "DXF.h"	// include dxframework
#include "LightShader.h"
#include "TextureShader.h"
#include "VerticalBlurShader.h"
#include "HorizontalBlurShader.h"
#include "KuwaharaShader.h"

class App1 : public BaseApplication
{
public:

	App1();
	~App1();
	void init(HINSTANCE hinstance, HWND hwnd, int screenWidth, int screenHeight, Input* in, bool VSYNC, bool FULL_SCREEN);

	bool frame();

protected:
	bool render();
	void firstPass();
	void verticalBlur();
	void horizontalBlur();
	void kuwaharaPass();
	void finalPass();
	void gui();

private:
	CubeMesh* cubeMesh;
	OrthoMesh* orthoMesh;
	OrthoMesh* halfOrthoMesh;
	LightShader* lightShader;
	TextureShader* textureShader;

	RenderTexture* renderTexture;
	RenderTexture* horizontalBlurTexture;
	RenderTexture* verticalBlurTexture;
	RenderTexture* downSampleTexture;
	RenderTexture* kuwaharaTexture;
	VerticalBlurShader* verticalBlurShader;
	HorizontalBlurShader* horizontalBlurShader;
	KuwaharaShader* kuwaharaShader;
	
	Light* light;
};

#endif