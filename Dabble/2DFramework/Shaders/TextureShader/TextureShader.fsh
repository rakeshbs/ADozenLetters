uniform sampler2D texture;
varying lowp vec2 fragmentTextureCoordinates;
varying mediump vec4 textureFragColor;

void main()
{
    lowp vec4 texel =  texture2D(texture, fragmentTextureCoordinates);
    gl_FragColor = texel * textureFragColor;
}