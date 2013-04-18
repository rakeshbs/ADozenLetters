attribute vec4 vertex;
attribute vec4 color;
attribute float mvpmatrixIndex;
uniform mat4 mvpmatrix[100];

varying vec4 frag_color;

void main()
{
    gl_Position = mvpmatrix[int(mvpmatrixIndex)] * vertex;
    frag_color = color;
}