extern vec4 a = vec4(1,1,1,1);
extern vec4 b = vec4(1,1,1,0);
extern int mode = 0;

vec4 lerp(float v,vec4 a,vec4 b)
{
	return a+v*(b-a);
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	//vec4 texturecolor = Texel(texture, texture_coords);
	vec4 texturecolor;
	if (mode==0) {
		texturecolor = lerp(texture_coords.x,a,b);
	} else {
		texturecolor = lerp(texture_coords.y,a,b);
	}
	return texturecolor*color;
}