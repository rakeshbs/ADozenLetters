attribute lowp mat4 mvpmatrix;
attribute lowp vec4 vertex;
attribute lowp vec4 color;

varying lowp vec4 frag_color;

void main()
{
    gl_Position = mvpmatrix * vertex;
    frag_color = color;
}