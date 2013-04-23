attribute lowp vec4 vertex;
attribute lowp vec2 textureCoordinate;
attribute lowp vec4 textureColor;
attribute lowp mat4 mvpmatrix;

varying lowp vec2 fragmentTextureCoordinates;
varying lowp vec4 textureFragColor;

void main()
{
    gl_Position = mvpmatrix * vertex;
    fragmentTextureCoordinates = textureCoordinate;
    textureFragColor = textureColor;
}