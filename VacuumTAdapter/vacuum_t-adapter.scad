// Vacuum T-adapter
// Author: Sebastian Bär
//
// This 3D model is licensed under the terms of the GNU Public License (GPL) V3
//
// The model creates two tubes with a T-style intersection.
// Each opening can have a differente diameter.
//
//          Flange           .----. Intersecting tube 
//          --------.        |    |
//          |         `------+    +------.
// Wide end |                            |  Narrow end
//          |         .------------------'
//          ---------'
//
// Configuration parameters

$fn = 15;

material_width = 4;                     // width of the material of the tubes
d_lateral = 58;                         // diameter of the straight part of the T
d_lateral_narrow = 35 + material_width; // diameter of the narrow end
l_lateral = 150;                        // length of the straight part of the T
d_across = 34;                          // diameter of the intersecting pipe
l_across = 70;                          // length of the intersecting pipe
offset_across = l_lateral * 0.6;        // position of the intersecting pipe
r_flange = 25;                          // radius of the flange between narrow and wide end
l_flange = 50;                          // length of the flange
cut = "none";                           // cut in half away for gluing ("none", "upper", "lower")

// Derived parameters

d_inner_lateral = d_lateral - material_width;
d_inner_lateral_narrow = d_lateral_narrow - material_width;
d_inner_across = d_across - material_width;

r_lateral = d_lateral / 2;
r_lateral_narrow = d_lateral_narrow / 2;
r_inner_lateral = d_inner_lateral / 2;
r_inner_lateral_narrow = d_inner_lateral_narrow / 2;

difference()
{
    union()
    {
        LateralCylinder(r_lateral, r_lateral_narrow, l_lateral, l_flange, r_flange);
        AcrossCylinder(d_across, l_across, offset_across);
    }
    union()
    {
        LateralCylinder(r_inner_lateral, r_inner_lateral_narrow, l_lateral, l_flange - material_width, r_flange);
        AcrossCylinder(d_inner_across, l_across, offset_across);
        
        // Cut away one half for gluing if necessary.
	    if(cut == "lower")
	    {
	    	translate([-r_lateral, -r_lateral, 0]) cube([d_lateral, r_lateral, l_lateral,]);
	    }
	    else if(cut == "upper")
	    {
	    	translate([-r_lateral, 0, 0]) cube([d_lateral, l_across, l_lateral,]);    	
	    }
    }
}

// Lateral cylinder
//
// Parameters:
//
//	r         - radius of the wide end
//  r_narrow   - radius of the narrow end
//  l         - overall length
//  l_flange  - length of the adapter flange
//  r_flange  - radius of the smooth transition between flange and cylinder
//
module LateralCylinder(r, r_narrow, l, l_flange, r_flange)
{
    dist_r = r_flange - r_narrow;
    l_transition = sqrt((2 * r_flange * dist_r) - pow(dist_r, 2));

    echo("r_lateral:", r_lateral);
    echo("transition: ", l_transition);
    echo("distr_r: ", dist_r);
   
    rotate_extrude(convexity = 10)
    rotate([180, 0, 90])
        difference()
        {
            union()
            {
                square([l, r_narrow]);
                square([l_flange + l_transition, r]);
            }
            translate([l_flange + l_transition, r_narrow + r_flange, 0]) circle(r_flange);
        }
}

// Intersecting cylinder
// 
// Parameters:
//
//	diameter - the cylinder diameter
//  length   - measured from the middle of the lateral cylinder
//  offset   - the position of the intersecting cylinder on the lateral cylinder
//
module AcrossCylinder(d, l, offset)
{
    rotate([-90, 0, 0]) translate([0, -offset, 0]) cylinder(d = d, h = l);
}