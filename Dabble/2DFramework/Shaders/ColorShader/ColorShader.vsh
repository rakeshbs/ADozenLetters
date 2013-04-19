uniform mat4 mvpmatrix[];
attribute vec4 vertex;
attribute vec4 color;
attribute float mvpmatrixIndex;


varying vec4 frag_color;

void main()
{
    int a = 0;
    gl_Position = mvpmatrix[0] * vertex;
    frag_color = color;
}