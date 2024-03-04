import gab.opencv.*;
import processing.video.*;

Movie video;
OpenCV opencv;
PImage canvas;

void setup() {
  size(640, 480);
  video = new Movie(this, "laser-video.mp4");
  opencv = new OpenCV(this, width, height);
  canvas = createImage(width, height, RGB);
  video.loop();
}

void draw() {
  image(video, 0, 0);

  opencv.loadImage(video);
  // Your processing code here...
}

void movieEvent(Movie m) {
  m.read();
}
