#version 330 core
layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 texture;

uniform mat4 view;
uniform mat4 model;
uniform mat4 projection;

out vec2 TexCoord;

void main() {

    TexCoord = texture;

    mat4 MVMatrix = view * model;
    mat3 NormalMatrix = mat3(transpose(inverse(model)));

    gl_Position = projection * MVMatrix * vec4(position, 1.0);
}