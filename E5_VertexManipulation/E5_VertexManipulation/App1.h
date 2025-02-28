// Application.h
#ifndef _APP1_H
#define _APP1_H

// Includes
#include "DXF.h"	// include dxframework
#include "ManipulationShader.h"
#include "MountainShader.h"


class App1 : public BaseApplication
{
public:

	App1();
	~App1();
	void init(HINSTANCE hinstance, HWND hwnd, int screenWidth, int screenHeight, Input* in, bool VSYNC, bool FULL_SCREEN);

	bool frame();

protected:
	bool render();
	void gui();

private:
	ManipulationShader* waterShader;
	MountainShader* mountainShader;
	PlaneMesh* waves;
	PlaneMesh* mountain;
	Light* light;
	float amplitude;
	float frequency;
	float speed;
};

#endif