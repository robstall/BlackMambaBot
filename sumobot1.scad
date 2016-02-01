use <../../SCADLib/batteries.scad>
use <../../SCADLib/plate.scad>
use <../../SCADLib/rpi_bplus_v2.scad>
use <../../SCADLib/sensors.scad>
use <../../SCADLib/servoS9001.scad>

// Dimensions in mm

drawBottonPlate = true;
drawRightSidePlate = true;
drawLeftSidePlate = true;
drawBackPlate = true;
drawComponents = true;

thickness = 3;
wheelDiameter = 66.5;
bottomPlateSize = [145 - thickness, 145, thickness];
sidePlateSize = [145, wheelDiameter - 5, thickness];
axelOffset = [wheelDiameter/2, wheelDiameter/2-bottomPlateSize[2]-5]; // x and z offset of axel

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
  translate([d[0] + 80, d[1]/2, 0])
    rotate([0, 0, 180])
      aa4BatteryHolder();
}

module rpi() {
  d = rpi_bplusSize();
  translate([5, -d[1]/2, 20])
     rpi_bplus(show_dongle = 1);
    //cube(d);
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


module bottomPlate() {
   translate([sidePlateSize[2], -bottomPlateSize[1]/2, -bottomPlateSize[2]]) 
      cube(bottomPlateSize); 
}

module sidePlate(side) {
  // This translation is easier if the plate is centered before rotating so that the left and right y offsets are the same.
  s = (side == "right" ? -1 : 1);
  difference() {
    translate([sidePlateSize[0]/2, s*(bottomPlateSize[0]/2 +  sidePlateSize[2]/2), sidePlateSize[1]/2-bottomPlateSize[2]])
       rotate([90, 0, 0])
        cube(sidePlateSize, center=true); 
      servo(side);
  } 
}

module backPlate() {
  d = [bottomPlateSize[1], sidePlateSize[1], sidePlateSize[2]];
  ventDim = [5, d[1]-25, d[2]];
  vents = 10;
  ventSpacing = d[0] / (vents+1);
  translate([0, -bottomPlateSize[0]/2, -bottomPlateSize[2]])
    rotate([90, 0, 90])
      difference() {
        cube(d);
        translate([30, d[2], 0])
          plate([16.5, 8, d[2]], r=1);
        for (n = [1:vents]) {
          translate([ventSpacing*n-ventDim[0]/2, 15, 0])
            plate(ventDim, r=ventDim[2]/2);
        }
      }
}

module topPlate() {
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
  
  if (drawComponents) {
    color("red") pb2sBatt();
    color("red") aaBatt();
    color("purple") rpi();
    color("blue") servo(side = "right");
    color("blue") servo(side = "left");
    color("yellow") wheel(side = "right");
    color("yellow") wheel(side = "left");
  }
  
  sizeLimit();
}


bot();
