attribute vec4 vertices;
uniform mat4 mvpmatrix;

void main()
{
    gl_Position = mvpmatrix * vertices;

}