attribute  mat4 mvpmatrix;
attribute  vec4 vertex;
attribute  vec4 color;

varying lowp vec4 frag_color;

void main()
{
    gl_Position = mvpmatrix * vertex;// vec4(vertex.x/100.0,vertex.y/200.0,vertex.z/56.0,1);
    frag_color = color;
}