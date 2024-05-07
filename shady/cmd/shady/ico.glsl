#define time iTime
#define mouse iMouse

float noise(vec2 st){
    return fract(sin(dot(vec2(12.23,74.343),st))*43254.);  
}

#define pi acos(-1.)
float noise2D(vec2 st){
  
  //id,fract
  vec2 id =floor(st);
  vec2 f = fract(st);
  
  float a = noise(id);
  float b = noise(id + vec2(1.,0.));
  float c = noise(id + vec2(0.,1.));
  float d = noise(id + vec2(1.));
  
  
  //f
  f = smoothstep(0.,.5,f);
  
  //mix
  float ab = mix(a,b,f.x);
  float cd = mix(c,d,f.x);
  return mix(ab,cd,f.y);
}

mat2 rot45 = mat2(0.707,-0.707,0.707,0.707);

mat2 rot(float a){
  float s = sin(a); float c = cos(a);
  return mat2(c,-s,s,c);
}
float fbm(vec2 st, float N, float rt){
    st*=3.;
 
  float s = .5;
  float ret = 0.;
  for(float i = 0.; i < N; i++){
     
      ret += noise2D(st)*s; st *= 2.9; s/=2.; st *= rot((pi*(i+1.)/N)+rt*8.);
      st.x += iTime/10.;
  }
  return ret;
  
}

#define FOV 70.0
#define imod(n, m) n - (n / m * m)

#define VERTICES 12
#define FACES 20

#define GLOW 4.0
#define MAX_BRIGHTNESS 0.4
#define THICKNESS 0.1
#define INTENSITY 0.2
#define X_OFFSET 0.33

float iX = .525731112119133606;
float iZ = .850650808352039932;

void icoVertices(out vec3[VERTICES] shape) {
    shape[0] = vec3(-iX,  0.0,    iZ);
    shape[1] = vec3( iX,  0.0,    iZ);
    shape[2] = vec3(-iX,  0.0,   -iZ);
    shape[3] = vec3( iX,  0.0,   -iZ);
    shape[4] = vec3( 0.0,  iZ,    iX);
    shape[5] = vec3( 0.0,  iZ,   -iX);
    shape[6] = vec3( 0.0, -iZ,    iX);
    shape[7] = vec3( 0.0, -iZ,   -iX);
    shape[8] = vec3(  iZ,   iX,  0.0);
    shape[9] = vec3( -iZ,   iX,  0.0);
    shape[10] = vec3(  iZ,  -iX,  0.0);
    shape[11] = vec3( -iZ,  -iX,  0.0);
}

mat2 rotate(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c, s, -s, c);
}

float line(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float t = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * t);
}

vec3 v[12];
vec2 p[12];

// using define trick to render different triangles
// not possible in loop on glslsandbox
#define tri(a, b, c) min(min(min(dis, line(uv, p[a], p[b])), line(uv, p[b], p[c])), line(uv, p[c], p[a]))

#define depth(a, b, c) (0.5 * clamp((0.1 * (v[a].z + v[b].z + v[c].z)), 0.0, 0.8))
//min(min(min(dep, v[a].z), v[b].z) v[c].z)


float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
    uv.x -= X_OFFSET;
    uv *= 4.0;

    // setup vertices
    icoVertices(v);

    // project
    for (int i = 0; i < 12; i++) {
        v[i].zy *= rotate(time * 0.03);
        v[i].xz *= rotate(time * 0.08);
        
        float scl = 1.0 / (1. + v[i].z * 0.2);
        float dist = distance(v[i].xyz, vec3(0, 0, -3));
        p[i] = v[i].xy * scl;
    }

    // ico faces
    float dis = 1.0;

    dis = min(dis,   tri(0,  4,  1)  + depth(0,  4,  1));
    dis = min(dis,   tri(0,  9,  4)  + depth(0,  9,  4));
    dis = min(dis,   tri(9,  5,  4)  + depth(9,  5,  4));
    dis = min(dis,   tri(4,  5,  8)  + depth(4,  5,  8));
    dis = min(dis,   tri(4,  8,  1)  + depth(4,  8,  1));
    dis = min(dis,   tri(8,  10, 1)  + depth(8,  10, 1));
    dis = min(dis,   tri(8,  3,  10) + depth(8,  3,  10));
    dis = min(dis,   tri(5,  3,  8)  + depth(5,  3,  8));
    dis = min(dis,   tri(5,  2,  3)  + depth(5,  2,  3));
    dis = min(dis,   tri(2,  7,  3)  + depth(2,  7,  3));
    dis = min(dis,   tri(7,  10, 3)  + depth(7,  10, 3));
    dis = min(dis,   tri(7,  6,  10) + depth(7,  6,  10));
    dis = min(dis,   tri(7,  11, 6)  + depth(7,  11, 6));
    dis = min(dis,   tri(11, 0,  6)  + depth(11, 0,  6));
    dis = min(dis,   tri(0,  1,  6)  + depth(0,  1,  6));
    dis = min(dis,   tri(6,  1,  10) + depth(6,  1,  10));
    dis = min(dis,   tri(9,  0,  11) + depth(9,  0,  11));
    dis = min(dis,   tri(9,  11, 2)  + depth(9,  11, 2));
    dis = min(dis,   tri(9,  2,  5)  + depth(9,  2,  5));
    dis = min(dis,   tri(7,  2,  11) + depth(7,  2,  11));

    // color the scene
    vec3 col = vec3(0.0, 0.2, 0.4);

    col += abs(THICKNESS / dis);
    col.r += dis;

    // dithering
    col += floor(dis + uv.y - fract(dot(fragCoord.xy, vec2(0.5, 0.75))) * 5.0) * 0.1;

    float fa1 = fbm(
        uv*rot(sin(uv.x)*0.001),
        5.0,
        3.0);
  
  float fa2 = fbm(
      vec2(0.01 * time, sin(dis * 8.0) + fa1*5.0),
      4.0,
      8.0);
  
  float fb3 = fbm(vec2(fa2), 3., 2.);
  
  vec3 col2 = vec3(0.05, 0.02, 0.1);
  
  col2.r += INTENSITY * (0.8 - dis) * fa2;
  col2.g += INTENSITY * fa2;
  col2.b += INTENSITY * fb3;

  float glow = 1.0 - clamp(0.8 * dot(uv.xy, uv.xy), 0.0, 1.0);
  col += GLOW * pow(glow, 8.0);

  fragColor.rgb = MAX_BRIGHTNESS * clamp(col*col2, 0.0, 1.0);
}
