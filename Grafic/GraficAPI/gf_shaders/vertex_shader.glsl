#version 330 core
layout (location = 0) in vec3 pos;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 texture;

uniform mat4 view;
uniform mat4 model;
uniform mat4 projection;
uniform vec3 CameraPos;

out vec2 TexCoord;
out vec4 eyePosition;
out vec3 eyeNorm;
out vec3 FPosition;

void main() {

    TexCoord = texture;

    mat4 MVMatrix = view * model;
    mat3 NormalMatrix = mat3(transpose(inverse(model)));

    eyeNorm = normalize( NormalMatrix * normal);
    eyePosition = model * vec4(pos,1.0);

    FPosition = vec3(model * vec4(pos, 1.0));

    gl_Position = projection * MVMatrix * vec4(pos, 1.0);
}