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

private int contourSize = 50;
private int laserThreshold = 250;

// Paint window, post-processed
void setup() {
  // width == 640, height == 480
  size(640, 480);
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
      if (contour.area() < contourSize) {
        // Convert contour into polygon
        // Get all the vertices of the polygon
        // PVector is each point, with x and y
        for (PVector point : contour.getPolygonApproximation().getPoints()) {
          // Paint to the window
          canvas.set((int)point.x, (int)point.y, color(255, 0, 0));  
        }
      }
    }

    // Display the canvas
    image(canvas, 0, 0);
  }
}

// Resets the canvas to a blank state
void resetCanvas() {
  background(0);  
}

// Handle key press for resetting the canvas
void keyPressed() {
  if (key == 'r' || key == 'R') {  
    resetCanvas();
  }
}

// Second window class for raw video output
// Works the same way as this class as a whole
public class SecondApplet extends PApplet {
  public void settings() {
    size(640, 480);
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
