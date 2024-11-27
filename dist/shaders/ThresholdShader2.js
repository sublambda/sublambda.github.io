
const ThresholdShader2 = {
	uniforms: {
	  'tDiffuse': { value: null },
	  'threshold': { value: 0.8 },
	  'uTime': { value: 0.0 }
	},

	vertexShader: /* glsl */`
        varying float x, y, z;
		varying vec2 vUv;
		varying float r_mod;

		void main() {
			vUv = uv;
			gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
            x = gl_Position.x; y = gl_Position.y; z = gl_Position.z;
            x += y; y -= x; z += x - y;
		}`,

	fragmentShader: /* glsl */`
        uniform float uTime;
		uniform sampler2D tDiffuse;
        uniform float threshold;
		varying vec2 vUv;

        varying float x, y, z;

		varying float r_mod;

		float rand(float s, float r) { return mod(mod(s, r + r_mod) * 112341.0, 1.0); }
        const vec4 clear = vec4(0,0,0,0);
        const vec4 black = vec4(0,0,0,1);

		void main() {
			vec4 color = texture2D(tDiffuse, vUv);
            float bright = 0.33333 * (color.r + color.g + color.b);

            if (bright < threshold) {
                float r = 0.3 + 0.5 * rand(uTime * 100.0, x * x);
                color = vec4(r,r,r,1.);
             } else
                color = clear;
			gl_FragColor = color;
		}`
};

export { ThresholdShader2 };
