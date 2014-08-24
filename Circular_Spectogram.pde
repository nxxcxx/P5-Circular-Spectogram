import ddf.minim.analysis.FFT;
import ddf.minim.*;
 
Minim minim;
AudioInput in;
///AudioPlayer in;
FFT         fft;
PGraphics canvas;
 
float THRES = 3;
float theta = 0;
int radius = 260;
float angVel = 0.15;
 
int halfWidth;
int halfHeight;
 
void setup() {
    size(600, 600, P2D);
    frameRate(60);
    smooth(16);
 
    halfWidth = width / 2;
    halfHeight = height / 2;
 
    minim = new Minim(this);
    // Microphone input 
    in = minim.getLineIn();
 
    // Local file
    //in = minim.loadFile("mySong.mp3");
    //in.play();
 
    // Create frequency(?) canvas
    canvas = createGraphics(600, 600, P2D);
    canvas.beginDraw();
    canvas.smooth(16);
    canvas.background(0);
    canvas.endDraw();
 
    // Print info to console
    fft = new FFT( in.bufferSize(), in.sampleRate() );
    println("buffer size = " + in.bufferSize());
    println("sample rate = " + in.sampleRate());
}
 
void draw() {
  background(0);
 
  fft.forward( in.mix );
 
  // Draw frequency circle
  renderFreqCircle();
 
  // Draw frequency wave
  renderFreqWave();
 
  frame.setTitle(int(frameRate) +  " fps");
}
 
void renderFreqCircle() {
 
    // Bind, translate and rotate canvas
    canvas.beginDraw();
    canvas.pushMatrix();
    canvas.translate(halfWidth, halfHeight);
    canvas.rotate(-radians(theta));
 
    // Render a black line to "erase" previously drawn lines
    canvas.stroke(0);
    canvas.strokeWeight(1);
    canvas.line(0, radius, 0, 0);
 
    // Render line shape to canvas
    canvas.beginShape();
    for(int i = 0; i <= radius; i++) {
        colorMode(HSB, 360, 100, 100, 100);
        //float data = abs( in.mix.get(i) );
        float data = fft.getBand(i+10);
        float hue = map(data, 0, THRES, 220, 200);
        float sat = map(data, 0, THRES, 100, 90);
        float br = map(data, 0, THRES, 0, 100);
        color c = color(hue, sat, br, 100);
        canvas.stroke(c);
        canvas.strokeWeight(1);
        canvas.vertex(0, radius - i);  // invert to draw from outside
        colorMode(RGB, 255);
    }
 
    // Unbind canvas
    canvas.endShape();
    canvas.popMatrix();
    canvas.endDraw();
    theta += angVel;
 
    // Render canvas to screen
    pushMatrix();
    translate(halfWidth, halfHeight);
    rotate(HALF_PI + radians(theta));
    image(canvas, -halfWidth, -halfHeight);
    popMatrix();
 
}
 
void renderFreqWave() {
    stroke(255);
    strokeWeight(1);
    noFill();
    pushMatrix();
    translate(halfWidth, halfHeight);
    beginShape();
    for(int i = 0; i < radius; i++) {
        float f = fft.getBand(i) * 0.75;
        f = constrain(f, 0, 60);
        vertex(i - radius, -f, i - radius, -f);
        vertex(i - radius, f, i - radius, f);
    }
    endShape();
    popMatrix();
}
