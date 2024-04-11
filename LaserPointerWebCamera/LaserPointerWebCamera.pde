// Import Libraries:
// - Open Computer Vision for Processing
// - Video
import gab.opencv.*;
import processing.video.*;

// Video capture for reading in video feed
Capture video;  
// Video processing object
OpenCV opencv;
// A canvas to paint on
PImage canvas; 
// Second window for video feed
SecondApplet secondApplet;  

private int   contourSize = 5;
private int   laserThreshold = 250;
color[] colors = {
          color(255, 0, 0),     // Red
          color(255, 165, 0),   // Orange
          color(255, 255, 0),   // Yellow
          color(0, 255, 0),     // Green
          color(0, 255, 255),   // Cyan
          color(0, 0, 255),     // Blue
          color(128, 0, 128)    // Purple
        };
int colorIndex = 0;
int brushSize = 3;



// Paint window, post-processed
void setup() {
  // width == 640, height == 480
  frameRate(60);
  size(1280, 960);
  video = new Capture(this, width, height);
  opencv = new OpenCV(this, width, height);
  canvas = createImage(width, height, RGB);  // Initialize the canvas
  video.start();

  // Initialize and display the secondary window
  secondApplet = new SecondApplet();
  String[] args = {"Second Applet"};
  PApplet.runSketch(args, secondApplet);

  // Initialize the canvas with a black background
  resetCanvas();  
}

/*
 * The "main" method:
 *   1. Read in video feed
 *   2. Give it to OpenCV
 *   3. Find all countours above threshold, turn the contours
 *      into polygons with points.
 *   4. Paint on the screen where the polygonial points are
 *
 */

void draw() {
  if (video.available()) {
    // Read in the video feed
    video.read();
    // Load the video feed into OpenCV obj
    opencv.loadImage(video);
    //turn to greyscale is necessary for thresholding
    opencv.gray();
    // Threshold pixels greater than the provided intensity
    // This is basically detecting the laser pointer on the board.
    // Computer vison looking for pixels of color > 250 (white)
    opencv.threshold(laserThreshold);

    //iterate through all the pixels above the threshold
    for (Contour contour : opencv.findContours()) {
      // Filter contours based on size
      if (contour.area() > contourSize) {
        // Convert contour into polygon
        // Get all the vertices of the polygon
        // PVector is each point, with x and y
        for (PVector point : contour.getPolygonApproximation().getPoints()) {
          // Paint to the window
          paint((int)point.x, (int)point.y, brushSize, brushSize);
        }
      }
    }

    // Display the paint canvas, making sure it is always on the top
    // surface.setAlwaysOnTop(true);
    image(canvas, 0, 0);
  }
}

void changeBrushSize() {
  brushSize += 2;
  if (brushSize == 35) {
    brushSize = 3;
  }
}

void switchPaintColor() {
  int ind = colorIndex;
  if (ind == colors.length) {
    colorIndex = 0;
  }
  colorIndex++;
  log("Color ind=" + colorIndex);
}

void paint(int x, int y, int w, int h) {
  // determine the size of the pixel to paint
  int start_x = x - (w / 2);
  int start_y = y - (h / 2);
  int end_x = start_x + w;
  int end_y = start_y + h;
  for (int i = start_x; i <= end_x; i++){
    for (int j = start_y; j <= end_y; j++){
      canvas.set(i, j, colors[colorIndex]);
    }
  }
}

// Resets the canvas to a blank state
void resetCanvas() {
    // Loop through all pixels in the canvas and set them to black
  for (int i = 0; i < canvas.pixels.length; i++) {
    canvas.pixels[i] = color(0);  // Set each pixel to black
  }
  canvas.updatePixels();  // Update the canvas with the new pixel values 
  log("User reset canvas.");
}

void log(String mes) {
  println(mes);
}

void keyPressed() {
  // Handle key press for resetting the canvas
  if (key == 'r' || key == 'R') {  
    resetCanvas();
  } 
  // Handle key press for switching colors
  if (key == 'c' || key == 'C') {
    switchPaintColor();
  }
  
  if (key == 'f' || key == 'F') {
    changeBrushSize();
  }
  
  if (key == 's' || key == 'S') {
      save("canvas_image.jpg");
      println("Canvas saved as 'canvas_image.jpg'");
  }
}

// Second window class for raw video output
// Works the same way as this class as a whole
public class SecondApplet extends PApplet {
  public void settings() {
    size(1280, 960);
  }

  public void setup() {
    background(0);
  }

  public void draw() {
    if (video.available()) {
      video.read();
      image(video, 0, 0); // Display the unprocessed camera feed
    }
  }
}
