// Lab1.cpp
// Lab 1 example, simple coloured triangle mesh
#include "App1.h"

App1::App1()
{
	waves = nullptr;
	waterShader = nullptr;
	mountainShader = nullptr;
}

void App1::init(HINSTANCE hinstance, HWND hwnd, int screenWidth, int screenHeight, Input *in, bool VSYNC, bool FULL_SCREEN)
{
	// Call super/parent init function (required!)
	BaseApplication::init(hinstance, hwnd, screenWidth, screenHeight, in, VSYNC, FULL_SCREEN);

	textureMgr->loadTexture(L"water", L"res/water.png");
	textureMgr->loadTexture(L"mountain", L"res/height.png");

	// Create Mesh object and shader object
	waves = new PlaneMesh(renderer->getDevice(), renderer->getDeviceContext());
	mountain = new PlaneMesh(renderer->getDevice(), renderer->getDeviceContext());
	waterShader = new ManipulationShader(renderer->getDevice(), hwnd);
	mountainShader = new MountainShader(renderer->getDevice(), hwnd);
	light = new Light;
	light->setDiffuseColour(1.0f, 1.0f, 1.0f, 1.0f);
	light->setDirection(0.7f, -0.7f, 0.0f);

	camera->setPosition(50.0f, 10.0f, 0.0f);

	//initialise wave height variables
	amplitude = 1.0f;
	frequency = 0.35f;
	speed = 1.5f;
	

}


App1::~App1()
{
	// Run base application deconstructor
	BaseApplication::~BaseApplication();

	// Release the Direct3D object.
	if (waves)
	{
		delete waves;
		waves = 0;
	}

	if (mountain)
	{
		delete mountain;
		mountain = 0;
	}

	if (waterShader)
	{
		delete waterShader;
		waterShader = 0;
	}

	if (mountainShader)
	{
		delete mountainShader;
		mountainShader = 0;
	}
}


bool App1::frame()
{
	bool result;

	result = BaseApplication::frame();
	if (!result)
	{
		return false;
	}
	
	// Render the graphics.
	result = render();
	if (!result)
	{
		return false;
	}

	return true;
}

bool App1::render()
{
	XMMATRIX worldMatrix, viewMatrix, projectionMatrix, translate, scale;

	// Clear the scene. (default blue colour)
	renderer->beginScene(0.39f, 0.58f, 0.92f, 1.0f);

	// Generate the view matrix based on the camera's position.
	camera->update();

	// Get the world, view, projection, and ortho matrices from the camera and Direct3D objects.
	worldMatrix = renderer->getWorldMatrix();
	viewMatrix = camera->getViewMatrix();
	projectionMatrix = renderer->getProjectionMatrix();

	// Send geometry data, set shader parameters, render object with shader
	waves->sendData(renderer->getDeviceContext());
	waterShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"water"), light, timer->getTime(), amplitude, speed, frequency);
	waterShader->render(renderer->getDeviceContext(), waves->getIndexCount());

	translate = XMMatrixTranslation(25.0f, -5.0f, 25.0f);
	scale = XMMatrixScaling(0.5f, 0.5f, 0.5f);
	worldMatrix = XMMatrixMultiply(translate, scale);
	mountain->sendData(renderer->getDeviceContext());
	mountainShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"mountain"), light);
	mountainShader->render(renderer->getDeviceContext(), mountain->getIndexCount());

	// Render GUI
	gui();

	// Swap the buffers
	renderer->endScene();

	return true;
}

void App1::gui()
{
	// Force turn off unnecessary shader stages.
	renderer->getDeviceContext()->GSSetShader(NULL, NULL, 0);
	renderer->getDeviceContext()->HSSetShader(NULL, NULL, 0);
	renderer->getDeviceContext()->DSSetShader(NULL, NULL, 0);

	// Build UI
	ImGui::Text("FPS: %.2f", timer->getFPS());
	ImGui::Checkbox("Wireframe mode", &wireframeToggle);
	ImGui::SliderFloat("Amplitude", &amplitude, 0.0f, 10.0f, "%.2f", 1.0f);
	ImGui::SliderFloat("Speed", &speed, 0.0f, 10.0f, "%.2f", 1.0f);
	ImGui::SliderFloat("Frequency", &frequency, 0.1f, 2.0f, "%.2f", 1.0f);



	// Render UI
	ImGui::Render();
	ImGui_ImplDX11_RenderDrawData(ImGui::GetDrawData());
}

