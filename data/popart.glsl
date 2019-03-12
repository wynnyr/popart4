#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

varying vec4 vertTexCoord;
uniform sampler2D texture;
uniform sampler2D uRamp;

//nook

void main() {

	vec3 lum = vec3(0.299, 0.587, 0.114);

    vec2 p = vertTexCoord.st;
    //vec2 aTc = fract(p * 2.0);

	vec2 aTc;
	aTc.x = fract(p.x * 2.0);
	aTc.y = fract(p.y * 1.0);


    aTc.x = (aTc.x / 1) + (1 - 1.0) * 0.5;
	aTc.y = (aTc.y / 1) + (1 - 1.0) * 0.5;

	vec3 color     = texture2D(texture, aTc).rgb;

	float greyscale = dot(color.rgb, lum);
	float gc = greyscale;

	//greyscale = 1.0 + (greyscale - 0.5) * 2.0;
	//greyscale = floor(greyscale * 2.0) * 0.5;

	float colArea = step(1.0, p.y * 1.0) * 2.0 + step(1.0, p.x * 2.0);
    colArea = 0.125 + colArea * 0.25;
	
	vec3 ramp = texture2D(uRamp, vec2(colArea, greyscale)).rgb;

	//color = vec3(0.5) + (color - vec3(0.5)) * 2.0;

	gl_FragColor = vec4(mix(vec3(gc), ramp, 0.5), 1.0);

}