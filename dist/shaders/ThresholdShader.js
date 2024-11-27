
const ThresholdShader = {
  uniforms: {
	'tDiffuse': { type: "t", value: null },
	'threshold': { value: 0.8 },
	'clearsaturation': { value: 0.5 },
	'color': { value: [0,0,0,1] },
	'clearcolor': { value: [0,0,0,0] },
	'uTime': { value: 0.0 }
  },

  vertexShader: /* glsl */`
        varying float x, y, z;
		varying vec2 vUv;
		varying float r_mod;

		void main() {
			vUv = uv;
			gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0 );
            x = gl_Position.x; y = gl_Position.y; z = gl_Position.z;
            x += y; y -= x; z += x - y;
		}`,

  fragmentShader: /* glsl */`
        uniform float uTime;
		uniform sampler2D tDiffuse;
        uniform float threshold;
        uniform float clearsaturation;
        uniform vec4 color;
        uniform vec4 clearcolor;
		varying vec2 vUv;
        varying float x, y, z;
		varying float r_mod;

		float rand(float s, float r) {
            return mod(mod(s, r + r_mod) * 112341.0, 1.0);
        }
        const vec4 clear = vec4(0,0,0,0);

		void main() {
			vec4 c = texture2D(tDiffuse, vUv);
            float bright = 0.33333 * (c.r + c.g + c.b);

            if (bright < threshold) {
                float r = rand(uTime * 1.0, x * y);
                //c = (r < clearsaturation) ? clearcolor : color;
//                c[3] = 1.0 - bright;
             } else
                c = clearcolor;
			gl_FragColor = c;
		}`
};

export { ThresholdShader };
