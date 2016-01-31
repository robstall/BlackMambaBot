use <../../SCADLib/batteries.scad>
use <../../SCADLib/plate.scad>
use <../../SCADLib/rpi_bplus_v2.scad>
use <../../SCADLib/sensors.scad>
use <../../SCADLib/servoS9001.scad>

// Dimensions in mm

thickness = 3;
wheelDiameter = 66.5;
bottomPlateSize = [145, 145, thickness];
sidePlateSize = [145, wheelDiameter - 5, thickness];
axelOffset = [wheelDiameter/2, wheelDiameter/2-bottomPlateSize[2]-5]; // x and z offset of axel

module pb2sBatt() {
  d = pb2sBatterySize();
  translate([0, -d[1]/2, 0])
    pb2sBattery();
}

module aaBatt() {
  d = aa4BatteryHolderSize();
  translate([d[1], -d[0]/2, 10])
    rotate([0, 0, 90])
      aa4BatteryHolder();
}

module rpi() {
  d = rpi_bplusSize();
  translate([0, -d[1]/2, 30])
     rpi_bplus(show_dongle = 1);
    //cube(d);
}

module servo(side) {
  s = (side == "right" ? -1 : 1);
  translate([axelOffset[0], s*bottomPlateSize[0]/2, axelOffset[1]])
    rotate([-s*90, 180, 0])
      servoS9001();
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
  translate([0, -bottomPlateSize[0]/2, -bottomPlateSize[2]])
    rotate([90, 0, 90])
      cube([bottomPlateSize[1], sidePlateSize[1], sidePlateSize[2]]);
}

module topPlate() {
}

module bot() {
  color("green") bottomPlate();
  color("darkgreen") sidePlate("right");
  color("darkgreen") sidePlate("left");
  color("gray") backPlate();
  
  color("red") pb2sBatt();
  color("red") aaBatt();
  color("purple") rpi();
  color("blue") servo(side = "right");
  color("blue") servo(side = "left");
  color("yellow") wheel(side = "right");
  color("yellow") wheel(side = "left");
  
}


bot();
