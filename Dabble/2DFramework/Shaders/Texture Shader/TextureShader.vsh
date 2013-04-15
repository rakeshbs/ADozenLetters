attribute vec4 vertices;
attribute vec2 textureCoordinates;
attribute vec4 textureColors;

attribute float mvpmatrixIndex;
uniform mat4 mvpmatrix[50];

varying vec2 fragmentTextureCoordinates;
varying lowp vec4 textureFragColor;

void main()
{
    gl_Position = mvpmatrix[int(mvpmatrixIndex)] * vertices;
    fragmentTextureCoordinates = textureCoordinates;
    textureFragColor = textureColors;
}