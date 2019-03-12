#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

const vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
const vec4  kRGBToI     = vec4 (0.596, -0.275, -0.321, 0.0);
const vec4  kRGBToQ     = vec4 (0.212, -0.523, 0.311, 0.0);

const vec4  kYIQToR   = vec4 (1.0, 0.956, 0.621, 0.0);
const vec4  kYIQToG   = vec4 (1.0, -0.272, -0.647, 0.0);
const vec4  kYIQToB   = vec4 (1.0, -1.107, 1.704, 0.0);

varying vec4 vertTexCoord;
uniform sampler2D texture;
uniform sampler2D uRamp;
uniform float hue;

//nook

void main() {

	vec3 lum = vec3(0.299, 0.587, 0.114);

    vec2 p = vertTexCoord.st;
    vec2 aTc = fract(p * 2.0);


    aTc.x = (aTc.x / 1) + (1 - 1.0) * 0.5;
	aTc.y = (aTc.y / 1) + (1 - 1.0) * 0.5;

	//vec3 color = texture2D(texture, aTc).rgb;

    // Sample the input pixel
	vec4 color = texture2D(texture, aTc).rgba;

    // Convert to YIQ
    float   YPrime  = dot (color, kRGBToYPrime);
    float   I      = dot (color, kRGBToI);
    float   Q      = dot (color, kRGBToQ);

    // Calculate the chroma
    float   chroma  = sqrt (I * I + Q * Q);

    // Convert desired hue back to YIQ
    Q = chroma * sin (hue);
    I = chroma * cos (hue);

    // Convert back to RGB
    vec4    yIQ   = vec4 (YPrime, I, Q, 0.0);
    //color.r = dot (yIQ, kYIQToR);
    //color.g = dot (yIQ, kYIQToG);
    //color.b = dot (yIQ, kYIQToB);

	float greyscale = dot(color.rgb, lum);
	float gc = greyscale;

	//greyscale = 1.0 + (greyscale - 0.5) * 2.0;
	//greyscale = floor(greyscale * 2.0) * 0.5;

	//float colArea = step(1.0, p.y * 2.0) * 2.0 + step(1.0, p.x * 2.0);
    float colArea = step(1.0, p.y * 2.0) * 2.0 + step(1.0, p.x * 2.0);

	colArea = 0.125 + colArea * 0.25;
	
	vec3 ramp = texture2D(uRamp, vec2(colArea, greyscale)).rgb;

	//color = vec3(0.5) + (color - vec3(0.5)) * 2.0;

	gl_FragColor = vec4(mix(vec3(gc), ramp, 0.7), 1.0);
    //gl_FragColor = vec4(mix(vec3(color), ramp, 0.7), 1.0);
}