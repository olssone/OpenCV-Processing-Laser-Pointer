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

private int contourSize = 5;
private int laserThreshold = 240;
color[] colors = {
  color(255, 0, 0), // Red
  color(255, 165, 0), // Orange
  color(255, 255, 0), // Yellow
  color(0, 255, 0), // Green
  color(0, 255, 255), // Cyan
  color(0, 0, 255), // Blue
  color(128, 0, 128) // Purple
};
int colorIndex = 0;
String[] brushShapes = {
  "square",
  "circle",
  "triangle"
};
int brushShapeIndex = 0;
int brushSize = 3;

int buttonWidth = 100;
int buttonHeight = 30;
int statusBarHeight = 40;

void setup() {
  frameRate(60);
  size(1000, 800);
  video = new Capture(this, width, height);
  opencv = new OpenCV(this, width, height);
  canvas = createImage(width, height, RGB); // Initialize the canvas
  video.start();

  // Initialize and display the secondary window
  secondApplet = new SecondApplet();
  String[] args = {"Second Applet"};
  PApplet.runSketch(args, secondApplet);

  resetCanvas();
}

void draw() {
  if (video.available()) {
    video.read();
    opencv.loadImage(video);
    opencv.gray();
    opencv.threshold(laserThreshold);

    for (Contour contour : opencv.findContours()) {
      if (contour.area() > contourSize) {
        for (PVector point : contour.getPolygonApproximation().getPoints()) {
          paint((int) point.x, (int) point.y, brushSize, brushSize, brushShapes[brushShapeIndex]);
        }
      }
    }

    image(canvas, 0, 0);
    drawStatusBar();
  }
}

void paint(int x, int y, int w, int h, String shape) {
  switch (shape) {
    case "square":
      // Draw a square
      int start_x = x - (w / 2);
      int start_y = y - (h / 2);
      int end_x = start_x + w;
      int end_y = start_y + h;
      for (int i = start_x; i < end_x; i++) {
        for (int j = start_y; j < end_y; j++) {
          canvas.set(i, j, colors[colorIndex]);
        }
      }
      break;
    case "circle":
      // Draw a circle
      for (int i = x - w; i <= x + w; i++) {
        for (int j = y - h; j <= y + h; j++) {
          if (dist(i, j, x, y) <= w / 2) { // Using the radius as half the width for simplicity
            canvas.set(i, j, colors[colorIndex]);
          }
        }
      }
      break;
    case "triangle":
      // Draw a triangle
      int peak_y = y - h / 2;
      int base_left_x = x - w / 2;
      int base_right_x = x + w / 2;
      int base_y = y + h / 2;
      for (int i = base_left_x; i <= base_right_x; i++) {
        for (int j = peak_y; j <= base_y; j++) {
          if ((j - peak_y) <= ((base_y - peak_y) * (i - base_left_x)) / (base_right_x - base_left_x) && 
              (j - peak_y) <= ((base_y - peak_y) * (base_right_x - i)) / (base_right_x - base_left_x)) {
            canvas.set(i, j, colors[colorIndex]);
          }
        }
      }
      break;
    default:
      // If shape is not recognized, do nothing or handle error
      break;
  }
}

void drawStatusBar() {
  fill(200);
  rect(0, height - statusBarHeight, width, statusBarHeight);
  fill(0);
  text("Shape: " + brushShapes[brushShapeIndex] + ", Size: " + brushSize + ", Color: " + hex(colors[colorIndex]), 10, height - 10);

  // Draw buttons for Reset, Save, Shape
  fill(150);
  rect(10, height - 35, buttonWidth, buttonHeight);
  rect(120, height - 35, buttonWidth, buttonHeight);
  rect(230, height - 35, buttonWidth, buttonHeight);
  rect(340, height - 35, buttonWidth, buttonHeight);
  rect(450, height - 35, buttonWidth, buttonHeight);
  fill(0);
  text("Reset", 20, height - 15);
  text("Save", 130, height - 15);
  text("Switch Shape", 240, height - 15);
  text("Change Color", 350, height - 15);
  text("Change Size", 460, height - 15);
}

void mousePressed() {
  if (mouseY >= height - buttonHeight && mouseY < height) {
    if (mouseX >= 10 && mouseX <= 10 + buttonWidth) {
      resetCanvas();
    } else if (mouseX >= 120 && mouseX <= 120 + buttonWidth) {
      saveCanvas();
    } else if (mouseX >= 230 && mouseX <= 230 + buttonWidth) {
      switchBrushShape();
    } else if (mouseX >= 340 && mouseX <= 340 + buttonWidth) {
      switchPaintColor();
    } else if (mouseX >= 450 && mouseX <= 450 + buttonWidth) {
      changeBrushSize();
    }
  }
}

void saveCanvas() {
  save("canvas_image.jpg");
  println("Canvas saved as 'canvas_image.jpg'");
}

void resetCanvas() {
  for (int i = 0; i < canvas.pixels.length; i++) {
    canvas.pixels[i] = color(0); // Set each pixel to black
  }
  canvas.updatePixels(); // Update the canvas with the new pixel values
  log("Canvas reset.");
}

void switchBrushShape() {
  brushShapeIndex = (brushShapeIndex + 1) % brushShapes.length;
}

void switchPaintColor() {
  int ind = colorIndex;
  if (ind == colors.length - 1) {
    colorIndex = 0;
  } else {
    colorIndex++;
  }
}

void changeBrushSize() {
  brushSize += 2;
  if (brushSize == 35) {
    brushSize = 3;
  }
}

void log(String mes) {
  println(mes);
}

// Second window class for raw video output
// Works the same way as this class as a whole
public class SecondApplet extends PApplet {
  public void settings() {
    size(1000, 800);
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
