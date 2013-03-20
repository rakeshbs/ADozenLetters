attribute vec4 vertices;
attribute vec4 color;
uniform mat4 mvpmatrix;
varying vec4 fragColor;
void main()
{
    gl_Position = mvpmatrix * vertices;
    fragColor = color;
}