uniform sampler2D texture;
varying lowp vec2 fragmentTextureCoordinates;
uniform lowp vec4 textureColor;

void main()
{
    lowp vec4 texel =  texture2D(texture, fragmentTextureCoordinates);
    gl_FragColor = texel * textureColor;
}