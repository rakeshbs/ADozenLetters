attribute vec4 vertices;
attribute vec2 textureCoordinates;
attribute vec4 textureColors;
attribute mat4 mvpmatrix;

varying vec2 fragmentTextureCoordinates;
varying lowp vec4 textureFragColor;

void main()
{
    gl_Position = mvpmatrix * vertices;
    fragmentTextureCoordinates = textureCoordinates;
    textureFragColor = textureColors;
}