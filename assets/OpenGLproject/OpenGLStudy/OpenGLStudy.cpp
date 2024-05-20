#include"GLEW/glew.h" 
#include"GLFW/glfw3.h" // include 순서가 glfw3.h 가 glew.h 뒤에 와야 합니다

#pragma comment(lib, "glew32.lib")
#pragma comment(lib, "opengl32.lib")
#pragma comment(lib, "glfw3.lib")

#include"stdio.h" 

const unsigned int WIN_W = 300;
const unsigned int WIN_H = 300;

int main(void)
{
    // start GLFW
    glfwInit();
    GLFWwindow* window = glfwCreateWindow(WIN_W, WIN_H, "Hello GLFW", NULL, NULL);
    glfwMakeContextCurrent(window);

    // start GLEW
    glewInit();

    // main loop
    while (!glfwWindowShouldClose(window))
    {
        //draw
        glClear(GL_COLOR_BUFFER_BIT);

        //end loop
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // done
    glfwTerminate();
    return 0;
}