uniform sampler2D tex;
uniform float multi;
in vec4 gl_Color;

void main() {
    gl_FragColor = texture2D(tex, gl_TexCoord[0].st);
    //huge hack so fonts work
    if (gl_FragColor.rgb == vec3(0.0,0.0,0.0) && gl_FragColor.a > 0.65) {
        // blur it with texture (texture should be near 0 though)
        gl_FragColor = vec4(0.0);
        vec2 blurSize = vec2(0.02, 0.02);

        gl_FragColor += texture2D(tex, gl_TexCoord[0].st+blurSize* -7.0)*0.0044299121055113265;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * -6.0)*0.00895781211794;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * -5.0)*0.0215963866053;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * -4.0)*0.0443683338718;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * -3.0)*0.0776744219933;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * -2.0)*0.115876621105;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * -1.0)*0.147308056121;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st )*0.159576912161;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * 1.0)*0.147308056121;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * 2.0)*0.115876621105;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * 3.0)*0.0776744219933;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * 4.0)*0.0443683338718;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * 5.0)*0.0215963866053;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st + blurSize * 6.0)*0.00895781211794;
        gl_FragColor += texture2D(tex, gl_TexCoord[0].st+blurSize * 7.0)*0.0044299121055113265;
        // gl_Color is what really matters
        gl_FragColor = gl_FragColor  + gl_Color; 

        //gl_FragColor = gl_Color + (texture2D(tex, gl_TexCoord[0].st;
        //vec2 blurSize = vec2(0.002, 0.002);
        //    + blurSize) + texture2D(tex, gl_TexCoord[0].st + blurSize * 2) + texture2D(tex, gl_TexCoord[0].st - blurSize) + texture2D(tex, gl_TexCoord[0].st- blurSize*2))/10;
    } else {
        gl_FragColor *= gl_Color;
    }
    gl_FragColor.a *= multi;
}
