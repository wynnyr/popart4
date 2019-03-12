import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;
import java.awt.Point;

Rectangle[] faces;

float[] faces_center_x;
float[] faces_center_y;

float[] faces_center_prev_x;
float[] faces_center_prev_y;

float[] faces_dist;

PShader popArt;
PImage  imgRamp;
PImage  imgSrc;
PImage  imgDest;

PImage  imgMask;
PImage  imgFrameBlack;
PImage  imgFrameGreen;
PImage  imgFrameYellow;

PImage  imgwait;

Capture video;
OpenCV opencv;

int faceDetectFlag    = 0;
int time_start_detect = 0;
int time_start_process= 0;

int lostDetectFlag;
int time_lost_detect;

ImageUploader imageUploader;
int minimalUploadInterval = 1000; 
boolean isImageUploading = false;
int lastImageUploadTime = 0; 

int saveImg = 0;

float framePos_x;
float framePos_y;

float loadingPos_x;
float loadingPos_y;

float angle = 0;

int modedebug = 0;
int modeManual = 0;
int bbb;

int waittime=10;

void captureEvent(Capture video) {
  video.read();
}

void setup() 
{
  fullScreen(P2D);
  //size(640, 480, P2D);
  frameRate(15);
  background (0, 0, 0);
  textSize(22);
  fill(0);
  
  imgRamp = loadImage("popart-ramp.png");
  imgMask = loadImage("Mask.png");
  imgFrameBlack = loadImage("frame_black.png");
  imgFrameGreen = loadImage("frame_green.png");
  imgFrameYellow = loadImage("frame_yellow.png");
  imgwait = loadImage("loadding.png");

  video = new Capture(this, 640, 480);
  video.start();
   
  popArt = loadShader("popart.glsl");
  popArt.set("uRamp",imgRamp);

  faceDetectFlag = 0;
  lostDetectFlag =0;

  //faces_detect = new Rectangle[3];
  faces_center_x = new float[3];
  faces_center_y = new float[3];
  faces_center_prev_x = new float[3];
  faces_center_prev_y = new float[3];
  faces_dist = new float[3];

  opencv = new OpenCV(this, video.width, video.height); 
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  
  framePos_x = (width-imgFrameBlack.width)*0.5;
  framePos_y = (height-imgFrameBlack.height)*0.5;
  
  loadingPos_x = ((width-imgwait.width*0.5)*0.5 )  +(imgwait.width*0.25);
  loadingPos_y = ((height-imgwait.height*0.5)*0.5) +(imgwait.height*0.25);
}

void draw() 
{
  opencv.loadImage(video); 
  faces = opencv.detect();
  
  float aspectRatioX = (float)width / video.width;
  float aspectRatioY = (float)height / video.height;
  
  shader(popArt);
  image(video,0,0, width, height);
  //filter(POSTERIZE, 2);
  resetShader();
  image(imgMask, 0, 0, width, height);

  if(saveImg == 1)
  {
     saveImg = 0;
     save(dataPath("img.png"));
     startImageUpload();  
     
  }

  if(imageUploader!=null) {
    if(imageUploader.isDataAvailable()) {
       isImageUploading = false;
     }
   } 

   
   image(video, 0, 0, width, height); 
   
if (modeManual == 1){
     image(imgFrameBlack, framePos_x, framePos_y);
     textAlign(CENTER); 
     fill(50, 0, 0); 
     textSize(30);
     text('M', 30, 30);
     
     
     if(bbb>2){
       bbb = 0;
     }
     if(bbb>0){
       bbb = bbb+1;
       image(imgFrameGreen, framePos_x, framePos_y);
     }
     else{
       image(imgFrameBlack, framePos_x, framePos_y); 
     }
}
else{
   
   int time_now = millis();

 if (faces!=null) {
   if (faces.length > 0) {

    //for (int i=0; i< faces.length; i++) { 
       noFill();
       strokeWeight(10);
       stroke(0,1,0);
       
       if (modedebug == 1){
         int i=0;
         float center_x = ((faces[i].x + faces[i].width) - faces[i].x)  * 0.5;
         float center_y = ((faces[i].y + faces[i].height) - faces[i].y) * 0.5;
         rect( faces[i].x*aspectRatioX, faces[i].y*aspectRatioY, faces[i].width*aspectRatioX, faces[i].height*aspectRatioY);
         point((faces[i].x+center_x)*aspectRatioX, (faces[i].y+center_y)*aspectRatioY);
       }
       
       if(faceDetectFlag==0)
       {
         faceDetectFlag = 1;
         faces_center_prev_x[0] = ((faces[0].x + faces[0].width) - faces[0].x)  * 0.5;
         faces_center_prev_y[0] = ((faces[0].y + faces[0].height) - faces[0].y) * 0.5; 
         time_start_detect = time_now;
         time_lost_detect  = time_now;
         time_start_process= 0;
       }
       else if (faceDetectFlag==1)
       {
         int timeCount = (time_now - time_start_detect)/1000;
         
         faces_center_x[0] = ((faces[0].x + faces[0].width) - faces[0].x)  * 0.5;
         faces_center_y[0] = ((faces[0].y + faces[0].height) - faces[0].y) * 0.5;
         
         faces_dist[0] = sqrt(sq(faces_center_x[0]-faces_center_prev_x[0])+sq(faces_center_y[0]-faces_center_prev_y[0]));
         
         if (modedebug == 1){
           text(faces_dist[0], 200, 600);
         }
         
         if((faces_dist[0]) < 6.0)
         {
           time_lost_detect = time_now;
           image(imgFrameGreen, framePos_x, framePos_y);

           textAlign(CENTER); 
           fill(255, 0, 0); 
           textSize(56);
          
           if (timeCount < 5){
             fill(0, 255, 0);
             textSize(40);
             text(timeCount, width/2,  220 + height/2);
             time_start_process = time_now;
           }
           else{
                //textSize(56);
                //fill(255,0, 0);
                //text("Take Photo", width/2,  height/2);
                faceDetectFlag = 2;
                saveImg = 1;
            }
              
         }
         else
         {
           int time_lost = (time_now - time_lost_detect);
           
           image(imgFrameYellow, framePos_x, framePos_y);
 
           if (time_lost > 500)
           {
             //time_lost = 0; 
             //time_start_detect = millis();
             faceDetectFlag = 0;
           }
           textSize(40);
           fill(0, 255, 255);
           text(timeCount, width/2,  220 + height/2);
             
         }
         
         faces_center_prev_x[0] =faces_center_x[0];
         faces_center_prev_y[0] =faces_center_y[0];
       }  
       else if (faceDetectFlag == 2)
       {
         int timeCount = (time_now - time_start_process)/1000; 
         //if(timeCount <  3)
          //{
          //  textSize(56);
          //  fill(255,0, 0);
          //  text("Take Photo", width/2,  height/2);
          //}
          //else if(timeCount >= 3 && timeCount < 10)
          if(timeCount < waittime)
          {
            showWait();  
            textSize(56);
            fill(255, 255, 255);
            text((waittime - timeCount), width/2,  10 + height/2); 
          } 
          else if(timeCount >= waittime){
             faceDetectFlag = 0;
          }
        }
     //}loop face
  }
  else{
      if (faceDetectFlag==0){
         time_start_detect = time_now;
         time_lost_detect  = time_now;
         time_start_process= 0;
         image(imgFrameBlack, framePos_x, framePos_y);
      }
      else if (faceDetectFlag==1)
      {
           int time_lost = (time_now - time_lost_detect);
           int timeCount = (time_now - time_start_detect)/1000;
           image(imgFrameBlack, framePos_x, framePos_y);
           if (time_lost > 100)
           {
             faceDetectFlag = 0;
           }
           textSize(40);
           fill(255, 255, 0);
           text(timeCount, width/2,  220 + height/2);     
       
      }  
      else if (faceDetectFlag == 2)
      {

        
        int timeCount = (time_now - time_start_process)/1000; 
         //if(timeCount <  3)
         // {
         //   textSize(56);
         //   fill(255,0, 0);
         //   text("Take Photo", width/2,  height/2);;
         // }
         // else if(timeCount >= 3 && timeCount < 10)
          if(timeCount < waittime)
          {
            showWait(); 
            textSize(56);
            fill(255, 255, 255);
            text((waittime - timeCount), width/2,  10 + height/2);
          } 
          else if(timeCount >= waittime){
             faceDetectFlag = 0;
          }
      }
    }
  }
}
}

void keyPressed() {
  
  if(keyCode == 32) {
    // space-bar
    saveImg = 1;
    bbb = 1;
  }
  else if(key == 'd')
  {// 'd'
    modedebug = 0;
  }
  else if(key == 'D')
  {// 'D'
    modedebug = 1;
  }
  else if(key == 'm')
  {// 'd'
    modeManual = 0;
  }
  else if(key == 'M')
  {// 'D'
    modeManual = 1;
  }
}
void showWait() {
  imageMode(CENTER);
  pushMatrix();
  angle = angle + 0.2;
  translate(loadingPos_x, loadingPos_y);
  rotate(angle);
  image(imgwait,0 , 0,imgwait.width*0.5,imgwait.height*0.5);
  popMatrix();
  imageMode(CORNERS);
}

void startImageUpload() {
  
  if(isImageUploading == false) {
    if((millis() - minimalUploadInterval) > lastImageUploadTime) {
      PImage imgDest = loadImage("img.png");
      imgDest.resize(0,300);

      println("The image will be sent to the server.");
      isImageUploading = true;
      
      imageUploader = new ImageUploader(imgDest);
    }
    else {
      println("The image is sent to fast.");  
    }
  }
  else {
    println("The image is still being stored.");
  }
          
}
