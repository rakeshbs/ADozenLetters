uniform sampler2D texture;
varying lowp vec2 fragmentTextureCoordinates;
uniform lowp vec4 textureColor;

void main()
{
    mediump vec4 texel =  texture2D(texture, fragmentTextureCoordinates);
    lowp vec4 finalColor = vec4(textureColor.r,textureColor.g,textureColor.b,texel.a*textureColor.a);
    gl_FragColor = finalColor;
}