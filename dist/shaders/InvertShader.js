
const InvertShader = {
	uniforms: {
	  'tDiffuse': { value: null },
	},

	vertexShader: /* glsl */`
		varying vec2 vUv;
		void main() {
			vUv = uv;
			gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
		}`,

	fragmentShader: /* glsl */`
		uniform sampler2D tDiffuse;
		varying vec2 vUv;
        const vec4 white = vec4(1.,1.,1.,1.);

		void main() {
			vec4 color = texture2D(tDiffuse, vUv);
            color.a = 0.0;
			gl_FragColor = vec4(1,1,1,1) - color;
		}`
};

export { InvertShader };
