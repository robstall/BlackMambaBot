use <../../SCADLib/batteries.scad>
use <../../SCADLib/plate.scad>
use <../../SCADLib/rpi_bplus_v2.scad>
use <../../SCADLib/sensors.scad>
use <../../SCADLib/servoS9001.scad>

// Dimensions in mm

drawBottonPlate = true;         // done
drawRightSidePlate = false;     // done
drawLeftSidePlate = false;      // done
drawBackPlate = false;          // done
drawComponents = true;
drawTopFwdPlate = false;
showSizeLimit = false;

drawFrontAssembly = true;
drawRightSideFwdPlate = false;
drawLeftSideFwdPlate = false;
drawBottomFwdPlate = false;
drawRightCaster = false;
drawLeftCaster = false;


groundClearance = 5;
thickness = 3;
wheelDiameter = 66.5;
bottomPlateSize = [145 - thickness, 145, thickness];
sidePlateSize = [145, wheelDiameter - groundClearance, thickness];
topFwdPlateSize = [145, 145, thickness];
casterBallDiameter = 15.6;
casterOverSize = 1.0;

axelOffset = [wheelDiameter/2, wheelDiameter/2-bottomPlateSize[2]-groundClearance]; // x and z offset of axel
wedgeAngle = 25; // Angle of wedge
wedgeX = 60; // Distance from rear wedge starts at
topJoinPt = [sidePlateSize[0], sidePlateSize[1] - (sidePlateSize[0] - wedgeX) * tan(wedgeAngle)]; // Top point where the fwd bow joins

//sideBlank("right");
//bottomBlank();
//casterBlank();
//casterTestPlate();
//ballClipBase();

// Uncomment these for the clips that hold down the caster wheels
//ballClip();
//translate([300,0,0]) mirror([1,0,0]) ballClip();

module sizeLimit() {
   translate([0, -100, -8])
     color("lightblue") square(200);
}

module pb2sBatt() {
  d = pb2sBatterySize();
  translate([d[1] + sidePlateSize[2]+1, -d[0]/2, 0])
    rotate([0, 0, 90])
      pb2sBattery(usbplug=true);
}

module aaBatt() {
  d = aa4BatteryHolderSize();
  translate([d[0]+sidePlateSize[2]+1, d[1]/2, 10])
    rotate([0, 0, 180])
      aa4BatteryHolder();
}

module rpi() {
  d = rpi_bplusSize();
  translate([d[0] + 45, -d[0]/2, 3])
    rotate([0, 0, 90])
      rpi_bplus(show_dongle = 1);
}

module servo(side) {
  s = (side == "right" ? -1 : 1);
  translate([axelOffset[0], s*bottomPlateSize[0]/2, axelOffset[1]])
    rotate([-s*90, 180, 0])
      servoS9001(oversize=1, screws=true);
}

module wheel(side) {
  s = (side == "right" ? -1 : 1);
  translate([axelOffset[0], s*bottomPlateSize[0]/2+s*10, axelOffset[1]])
    rotate([-s*90, 0, 0])
      cylinder(d=wheelDiameter, h=5); 
}

module casterBlank() {
  r = (casterBallDiameter) / 2;
  fw = r / 1.5; // Finger width
  
  difference() {
    for (i = [0:1]) {
      mirror([i,i,0]) {
        difference() {
          union() {
            translate([0, fw/2, r]) rotate([90, 0, 0]) cylinder(h=fw,r=r+3);
            translate([-(r+3), -fw/2, 0]) cube([2*(r+3), fw, r]);
            translate([-r-10,-fw/2,groundClearance+bottomPlateSize[2]])cube([2*(r+10), fw, 3]);
          }
          translate([-15, -15, -30+groundClearance+bottomPlateSize[2]]) cube([30, 30, 30]);
        } 
      }
    }
    translate([0, 0, r-casterOverSize]) sphere(r=(r+casterOverSize/2));
  }
}

// Test plate with caster cutout to for test printing
module casterTestPlate() {
  r = (casterBallDiameter) / 2;
  difference() {
     translate([-36/2,-36/2,groundClearance]) cube([36, 36,    bottomPlateSize[2]]);
    
     //casterBlank();
     translate([0, 0, r-casterOverSize]) sphere(r=(r+casterOverSize/2));
  }
}

module caster(side) {
  s = (side == "right" ? -1 : 1);
  translate([bottomPlateSize[0]+sidePlateSize[2]+casterBallDiameter*0.75,
            s*(bottomPlateSize[1]/2-casterBallDiameter-5), 
            casterBallDiameter/2-groundClearance-bottomPlateSize[2]])
    sphere(casterBallDiameter / 2);
}

module bracket() {
  t = bottomPlateSize[2] / 2; 
  cube([10, 10, t]);
  cube([10, t, 10]);
  translate([t, 0, 0])
    rotate([0, -90, 0])
      linear_extrude(t)
        polygon([[t,t], [t,10], [10,t]]);
  translate([10, 0, 0])
    rotate([0, -90, 0])
      linear_extrude(t)
        polygon([[t,t], [t,10], [10,t]]);
}

module bottomBlank() {
  d = bottomPlateSize;
  difference() {
    cube(d);
    for (x = [0:2]) {
      for (y = [0:11]) {
        translate([15+x*40, 15+y*10, 0])
          plate([35, 5, d[2]], r=d[2]/2);
      }
    }
  }
}

module bottomPlate() {
   translate([sidePlateSize[2], -bottomPlateSize[1]/2, -bottomPlateSize[2]]) 
      bottomBlank(); 
}

module sideBlank(side) {  
  d = sidePlateSize;
  m = side == "right" ? [0,0,1] : [0,0,0];
  //difference() {
    mirror(m) {
      // Blank side
      pts = [
        [0, 0],
        [0, d[1]],
        [wedgeX, d[1]],
        topJoinPt,
        [d[0], 0]
      ];
      
      difference() {
        linear_extrude(height=d[2]) 
          polygon(points=pts);
          // The side vents
        for (i = [2:7]) {
          translate([wedgeX + i*10, 10, 0])
            plate([5, 40-i*4.5, d[2]], r=d[2]/2);
        }
      }
    
      // Bottom flange and brackets
      translate([d[2], bottomPlateSize[2], d[2]]) {
        l = (d[0]-d[2]-30)/2;
        difference() {
          cube([d[0]-d[2], d[2], 10]);
          translate([10, 0, d[2]])
            cube([l, d[2], 10 - d[2]]);
          translate([10*2+l, 0, d[2]])
            cube([l, d[2], 10 - d[2]]);
        }
      }  
    
      // Rear flange and brackets
      translate([d[2], bottomPlateSize[2], d[2]]) {
        h = d[1]-d[2]-bottomPlateSize[2];
        difference() {
          cube([d[2], h, 10]);
          translate([0, 10, d[2]])
            cube([d[2], h - 20, 10 - d[2]]);
        }
      }
    
      // Top flange and brackets
      translate([d[2], d[1]-2*d[2], d[2]]) {
        difference() {
          cube([wedgeX - d[2], d[2], 10]);
          translate([10, 0, d[2]])
            cube([wedgeX-d[2]-20, d[2], 10-d[2]]);
        }
      }
    
      // Front bracket
      translate([d[0]-d[2], bottomPlateSize[2], d[2]])
        cube([d[2], topJoinPt[1]-2*d[2], 10]);
    
      // Wedge flange and bracket
      translate([wedgeX-1.3, d[1]-2*d[2]+.1, d[2]])
        rotate([0, 0, -wedgeAngle]) {
          cube([93, d[2], d[2]]);
          cube([10, d[2], 10]);
          translate([93-10, 0, 0])
            cube([10, d[2], 10]);
        }   
     
//      // The side vents
//      for (i = [2:7]) {
//        translate([wedgeX + i*10, 10, 0])
//          plate([5, 40-i*4.5, d[2]], r=d[2]/2);
//      }
//    }
  }
}

module sidePlate(side) {
  s = (side == "right" ? -1 : 1);
  yOff = (side == "right" ? -2 * sidePlateSize[2] : 0);
  difference() {
    translate([0, s*bottomPlateSize[1]/2 + sidePlateSize[2] + yOff, -bottomPlateSize[2]])
       rotate([90, 0, 0]) 
          sideBlank(side);
      servo(side);
  } 
}

module sideFwdBlank() {
  d = sidePlateSize;
  tipX = topJoinPt[1]/tan(wedgeAngle);
  pts = [
    [0, 0],
    [0, topJoinPt[1]],
    [tipX, 0]
  ];
  linear_extrude(height=d[2])
    polygon(points=pts);
}

module sideFwdPlate(side) {
  s = (side == "right" ? -1 : 1);
  yOff = (side == "right" ? - sidePlateSize[2] : 0);
  translate([sidePlateSize[0], s*bottomPlateSize[1]/2 + sidePlateSize[2] + yOff, -bottomPlateSize[2]])
       rotate([90, 0, 0])
          sideFwdBlank();
}

module backPlate() {
  d = [bottomPlateSize[1], sidePlateSize[1], sidePlateSize[2]];
  ventDim = [5, d[1]-25, d[2]];
  vents = 10;
  ventSpacing = d[0] / (vents+1);
  translate([0, -bottomPlateSize[0]/2-thickness/2, -bottomPlateSize[2]])
    rotate([90, 0, 90])
      difference() {
        cube(d);
        translate([31.5, d[2], 0])
          plate([16.5, 8, d[2]], r=1);
        for (n = [1:vents]) {
          translate([ventSpacing*n-ventDim[0]/2, 15, 0])
            plate(ventDim, r=ventDim[2]/2);
        }
      }
}

module topPlate() {
}

module topFwdPlate() {
  d = topFwdPlateSize;
  translate([wedgeX, -d[1]/2, 55])
    rotate([0, wedgeAngle, 0]) {
      //scale([0.5, 0.5, 0.1])
      //  surface(file = "BlackMamba.png", invert=true);
      cube(topFwdPlateSize);
    }
}

module bottomFwdPlateBlank() {
  pts = [
    [0, 0],
    [33, 0],
    [33, bottomPlateSize[1]],
    [0, bottomPlateSize[1]]
  ];
  linear_extrude(height=bottomPlateSize[2])
    polygon(pts);
  translate([0, 0, bottomPlateSize[2]])
    difference() {
      cube([bottomPlateSize[2], 10, 10]);
      translate([0, 5, 5]) rotate([0,90,0]) cylinder(bottomPlateSize[2]*2, d=2.5);
    }
  translate([0, bottomPlateSize[1]-10, bottomPlateSize[2]])
    difference() {
      cube([bottomPlateSize[2], 10, 10]);
      translate([0, 5, 5]) rotate([0,90,0]) cylinder(bottomPlateSize[2]*2, d=2.5);
    }
   translate([-5, bottomPlateSize[1]/2-10, bottomPlateSize[2]])
    cube([10, 20, bottomPlateSize[2]]);
  
  // Front solid wedge bit
  translate([0, bottomPlateSize[1], 0]) {
    rotate([90,0,0]) {
      tipX = topJoinPt[1]/tan(wedgeAngle);
      width = tipX - 33;
      pts2 = [
        [tipX-width, 0],
        [tipX, 0],
        [tipX-width, width*tan(wedgeAngle)]
      ];
      linear_extrude(height=bottomPlateSize[1])
        polygon(points=pts2);
    }
  }
}

module bottomFwdPlate() {
  d = bottomPlateSize;
  difference() {
    translate([d[0]+sidePlateSize[2], -d[1]/2, -d[2]])
      bottomFwdPlateBlank();
    caster("right");
    caster("left");
  }
}

module ballClipBase() {
  difference() {
    translate([-10,0,0]) cube([20, 10, 3]);
    translate([-5,5,0]) cylinder(5, d=2.5);
  }
  translate([0, 3, 3]) cube([22, 4, 9]);
}

module ballClip() {
  difference() {
    translate([152, -33, 0])
      rotate([0, 0, -90])
        ballClipBase();
    frontAssembly();
    topFwdPlate();
    caster("right");
  }
}

module frontAssembly() {
  difference() {
    union() {
      //color("yellow") caster("right");
      //color("yellow") caster("left");
      color("orange") sideFwdPlate("right");
      color("orange") sideFwdPlate("left");
      color("orange") bottomFwdPlate();
    }
    // Cutout space for fwd plate and trim the point off the nose to make it printable
    topFwdPlate(); 
    translate([0,0,1]) topFwdPlate();
    translate([bottomPlateSize[0]+topJoinPt[1]/tan(wedgeAngle)-5, -150, -5]) cube([10, 300, 10]);
    
    // Marble casters
    color("yellow") caster("right");
    color("yellow") caster("left");
  }
}

module bot() {
  if (drawBottonPlate) 
    color("green") bottomPlate();
  if (drawRightSidePlate)
    color("darkgreen") sidePlate("right");
  if (drawLeftSidePlate)
    color("darkgreen") sidePlate("left");
  if (drawBackPlate)
    color("blue") backPlate();
  if (drawTopFwdPlate)
    color("yellow") topFwdPlate();
  
  if (drawFrontAssembly) {
    frontAssembly();
  }
  else {
    if (drawRightCaster)
      color("yellow") caster("right");
    if (drawLeftCaster)
      color("yellow") caster("left"); 
    if (drawRightSideFwdPlate)
      color("orange") sideFwdPlate("right");
    if (drawLeftSideFwdPlate)
      color("orange") sideFwdPlate("left");
    if (drawBottomFwdPlate)
      color("orange") bottomFwdPlate();
  }
  
  if (drawComponents) {
    color("red") pb2sBatt();
    color("red") aaBatt();
    color("purple") rpi();
    color("blue") servo(side = "right");
    color("blue") servo(side = "left");
    color("yellow") wheel(side = "right");
    color("yellow") wheel(side = "left");
  }
  
  if (showSizeLimit)
    sizeLimit();
}


bot();
