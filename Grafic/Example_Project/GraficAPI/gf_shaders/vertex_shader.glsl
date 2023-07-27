#version 330 core
layout (location = 0) in vec3 position;

uniform mat4 view;
uniform mat4 model;
uniform mat4 projection;

void main() {

    mat4 MVMatrix = view * model;
    mat3 NormalMatrix = mat3(transpose(inverse(model)));

    gl_Position = projection * MVMatrix * vec4(position, 1.0); //MVMatrix
}