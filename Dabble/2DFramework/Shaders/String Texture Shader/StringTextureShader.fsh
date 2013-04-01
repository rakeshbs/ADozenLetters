uniform sampler2D texture;
varying lowp vec2 fragmentTextureCoordinates;
varying mediump vec4 textureFragColor;

void main()
{
    mediump vec4 texel =  texture2D(texture, fragmentTextureCoordinates);
    lowp vec4 finalColor = vec4(textureFragColor.r,textureFragColor.g,textureFragColor.b,texel.a*textureFragColor.a);
    gl_FragColor = finalColor;
}