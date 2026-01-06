// Units: mm

VIEW_MODE = "exploded";      // "assembled" or "exploded"
EXPLODE_GAP = 24;

SHOW_STRUCTURE = true;
SHOW_PANELS    = true;
SHOW_SOLAR     = true;

SHOW_EPS       = true;
SHOW_OBC       = true;
SHOW_COMMS     = true;
SHOW_SENSORS   = true;
SHOW_PAYLOAD   = true;

SHOW_ADCS      = true;
SHOW_HARNESS   = true;
SHOW_DECKS     = true;
SHOW_LEGEND    = true;

U = 100;
Z = 113.5;

FRAME_WALL  = 2.5;
CORNER_POST = 10;
RAIL_THICK  = 4.0;
RAIL_INSET  = 6.0;

PANEL_THICK = 1.5;
PANEL_CLEAR = 0.8;

$fn = 48;

// Color system
C_STRUCT  = [0.10, 0.10, 0.12];
C_PANEL   = [0.85, 0.85, 0.88];
C_SOLAR   = [0.02, 0.20, 0.55];
C_EPS     = [0.95, 0.55, 0.05];
C_OBC     = [0.05, 0.75, 0.35];
C_COMMS   = [0.95, 0.80, 0.10];
C_SENSOR  = [0.00, 0.80, 0.85];
C_PAYLOAD = [0.10, 0.55, 0.95];
C_ADCS    = [0.70, 0.25, 0.95];
C_WIRE    = [0.55, 0.55, 0.55];

PANEL_EX = (VIEW_MODE=="exploded") ? 60 : 0;
SOLAR_EX = PANEL_EX;
ANT_EX   = (VIEW_MODE=="exploded") ? 85 : 0;

function ex(i) = (VIEW_MODE=="exploded") ? i*EXPLODE_GAP : 0;

module blk(x,y,z,c){ color(c) cube([x,y,z],center=true); }

module pcb(x,y,t,c,hole_r=1.6,hole_in=6){
    color(c)
    difference(){
        cube([x,y,t],center=true);
        for(sx=[-1,1],sy=[-1,1])
            translate([sx*(x/2-hole_in),sy*(y/2-hole_in),0])
                cylinder(h=t+1,r=hole_r,center=true);
    }
}

// I added standoffs so internal boards read as real assemblies, not floating blocks
module standoffs(x,y,z,hole_in=6,r=2.0,h=8){
    color(C_STRUCT)
    for(sx=[-1,1],sy=[-1,1])
        translate([sx*(x/2-hole_in),sy*(y/2-hole_in),z])
            cylinder(h=h,r=r,center=true);
}

module wire(p1,p2,r=1.3){
    color(C_WIRE)
    hull(){ translate(p1)sphere(r=r); translate(p2)sphere(r=r); }
}

module frame(){
    for(sx=[-1,1],sy=[-1,1])
        translate([sx*(U/2-CORNER_POST/2),sy*(U/2-CORNER_POST/2),Z/2])
            blk(CORNER_POST,CORNER_POST,Z,C_STRUCT);

    for(sx=[-1,1],sy=[-1,1])
        translate([sx*(U/2-RAIL_INSET),sy*(U/2-RAIL_INSET),Z/2])
            blk(RAIL_THICK,RAIL_THICK,Z,C_STRUCT);

    ring_t=FRAME_WALL;
    ring_o=[U,U,ring_t];
    ring_i=[U-2*FRAME_WALL,U-2*FRAME_WALL,ring_t+0.2];

    translate([0,0,ring_t/2]) color(C_STRUCT)
        difference(){ cube(ring_o,center=true); cube(ring_i,center=true); }

    translate([0,0,Z-ring_t/2]) color(C_STRUCT)
        difference(){ cube(ring_o,center=true); cube(ring_i,center=true); }
}

module decks(){
    d=U-2*(FRAME_WALL+2);
    t=1.8;
    translate([0,0,FRAME_WALL+t/2]) color(C_STRUCT) cube([d,d,t],center=true);
    translate([0,0,Z-FRAME_WALL-t/2]) color(C_STRUCT) cube([d,d,t],center=true);
}

module panel_plate(w,h,t,cut=false){
    difference(){
        cube([t,w,h],center=true);
        for(sy=[-1,1],sz=[-1,1])
            translate([0,sy*(w/2-10),sz*(h/2-10)])
                rotate([0,90,0]) cylinder(h=t+2,r=1.6,center=true);
        if(cut) translate([0,0,-h/2+25]) cube([t+2,18,10],center=true);
    }
}

module panels(){
    px=U-2*(RAIL_INSET+PANEL_CLEAR);
    h=Z-2*FRAME_WALL;
    t=PANEL_THICK;
    i=(U/2-(RAIL_INSET+PANEL_CLEAR))-t/2;

    translate([ i+PANEL_EX,0,Z/2]) color(C_PANEL,0.7) panel_plate(px,h,t,false);
    translate([-i-PANEL_EX,0,Z/2]) color(C_PANEL,0.7) panel_plate(px,h,t,false);
    translate([0, i+PANEL_EX,Z/2]) rotate([0,0,90]) color(C_PANEL,0.7) panel_plate(px,h,t,false);
    translate([0,-i-PANEL_EX,Z/2]) rotate([0,0,90]) color(C_PANEL,0.7) panel_plate(px,h,t,true);
}

module solar_panels(){
    px=U-2*(RAIL_INSET+PANEL_CLEAR);
    h=Z-2*FRAME_WALL;
    t=1.2;
    i=(U/2-(RAIL_INSET+PANEL_CLEAR)) + PANEL_THICK + t/2 + 1;
    sx=px*0.75; sz=h*0.75;

    translate([ i+SOLAR_EX,0,Z/2]) color(C_SOLAR) cube([t,sx,sz],center=true);
    translate([-i-SOLAR_EX,0,Z/2]) color(C_SOLAR) cube([t,sx,sz],center=true);
    translate([0, i+SOLAR_EX,Z/2]) color(C_SOLAR) cube([sx,t,sz],center=true);
    translate([0,-i-SOLAR_EX,Z/2]) color(C_SOLAR) cube([sx,t,sz],center=true);
}

module eps_pack(){
    z=FRAME_WALL+18+ex(0);
    color(C_EPS){
        translate([-15,0,z]) rotate([90,0,0]) cylinder(h=40,r=9,center=true);
        translate([ 15,0,z]) rotate([90,0,0]) cylinder(h=40,r=9,center=true);
        translate([0,0,z+10]) cube([50,42,8],center=true);
    }

    translate([0,35,z+14+ex(1)]){
        standoffs(60,35,-4);
        pcb(60,35,1.6,C_EPS);
    }

    translate([-30,-30,z+16+ex(1)]) blk(28,18,8,C_EPS);
    translate([ 30,-30,z+16+ex(1)]) blk(28,18,8,C_EPS);
}

module obc_pack(){
    z=FRAME_WALL+48+ex(2);
    translate([0,0,z]){
        standoffs(60,22,-4);
        pcb(60,22,1.6,C_OBC);
    }
    translate([25,0,z+8]) blk(18,15,6,C_OBC);
}

module comms_pack(){
    z=FRAME_WALL+58+ex(2);
    translate([-30,25,z]){
        pcb(32,16,1.6,C_COMMS,0);
        translate([6,0,4]) blk(12,10,6,C_COMMS);
    }
    translate([0,-(U/2-(RAIL_INSET+PANEL_CLEAR))-5-ANT_EX,FRAME_WALL+28])
        rotate([90,0,0]) color(C_COMMS) cylinder(h=90,r=1.4);
}

module sensors_pack(){
    z=FRAME_WALL+86+ex(4);
    translate([0,0,z]){
        standoffs(70,70,-4);
        pcb(70,70,1.6,C_SENSOR);
    }
    translate([-20,-15,z+8]){
        pcb(34,26,1.6,C_SENSOR,0);
        translate([0,0,6]) blk(22,22,6,C_SENSOR);
    }
    translate([20,-20,z+5]) blk(12,12,4,C_SENSOR);
    translate([20,20,z+6]){
        blk(14,14,4,C_SENSOR);
        translate([0,0,4]) color(C_SENSOR) cylinder(h=4,r=3,center=true);
    }
}

module payload_pack(){
    z=FRAME_WALL+72+ex(3);
    translate([0,30,z]) color(C_PAYLOAD)
        difference(){ cube([36,26,18],center=true);
                      translate([0,13,0]) cylinder(h=25,r=6,center=true); }
    translate([0,30,z-10]){
        standoffs(28,24,-4,5,1.8,7);
        pcb(28,24,1.6,C_PAYLOAD,1.2,5);
    }
}

module adcs_pack(){
    z=FRAME_WALL+42+ex(1);
    blk(18,18,18,C_ADCS);
    color(C_ADCS){
        translate([0,35,z]) cube([50,4,4],center=true);
        translate([35,0,z+25]) cube([4,50,4],center=true);
        translate([-35,0,z+25]) cube([4,4,50],center=true);
    }
}

module legend(){
    x = U/2 + 120;
    y = 0;
    z = Z - 10;
    g = 14;

    cols = [C_STRUCT,C_PANEL,C_SOLAR,C_EPS,C_OBC,C_COMMS,C_SENSOR,C_PAYLOAD,C_ADCS,C_WIRE];
    labs = ["STRUCT","PANEL","SOLAR","EPS","OBC","COMMS","SENS","PAYLD","ADCS","WIRE"];

    for(i=[0:9]){
        // chip
        translate([x, y, z - i*g])
            color(cols[i]) cube([10,10,6], center=true);

        // label (make it face the camera)
        translate([x + 14, y, z - i*g])
            color([0,0,0])
            rotate([90,0,0])               // <-- this is the key
                linear_extrude(height=0.8)
                    text(labs[i], size=6, halign="left", valign="center");
    }
}


module cubesat(){
    if(SHOW_STRUCTURE) frame();
    if(SHOW_DECKS) decks();
    if(SHOW_PANELS) panels();
    if(SHOW_SOLAR) solar_panels();
    if(SHOW_EPS) eps_pack();
    if(SHOW_OBC) obc_pack();
    if(SHOW_COMMS) comms_pack();
    if(SHOW_SENSORS) sensors_pack();
    if(SHOW_PAYLOAD) payload_pack();
    if(SHOW_ADCS) adcs_pack();
    if(SHOW_HARNESS){
        wire([-20,-10,25],[20,20,55]);
        wire([10,25,40],[-10,-25,80]);
    }
    if(SHOW_LEGEND) legend();
}

cubesat();

