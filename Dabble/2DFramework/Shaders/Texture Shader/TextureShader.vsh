attribute vec4 vertices;
attribute vec2 textureCoordinates;
uniform mat4 mvpmatrix;
varying vec2 fragmentTextureCoordinates;

void main()
{
    gl_Position = mvpmatrix * vertices;
    fragmentTextureCoordinates = textureCoordinates;
}