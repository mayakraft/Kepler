// Planet locations in the J2000 ecliptic plane, + X-axis aligned toward the equinox
//
// robby kraft
// mit open source license
//
// reference:  http://ssd.jpl.nasa.gov/txt/aprx_pos_planets.pdf
//   more information at http://iau-comm4.jpl.nasa.gov/XSChap8.pdf
//
// time is in J2000: the units are centuries after the year 2000
//   time = (year-2000)/100 + day_of_the_year/36525
//   where day_of_the_year would be 42 for February 11th.

#include <math.h>

#define PI 3.141592653589793

double KeplersEquation(double E, double M, double e)
{
	double deltaM = M - ( E - (e*180.0/PI) * sin(E*PI/180.0) );
	double deltaE = deltaM / (1.0 - e*cos(E*PI/180.0));
	return E + deltaE;
}

void calculateLocationOfPlanet(int planet, double time, double *planet_x, double *planet_y, double *planet_z)
{
//                               a              e              I              L          long.peri.     long.node.
//                              AU             rad            deg            deg            deg            deg
static double _elements[]= {0.38709927,    0.20563593,    7.00497902,   252.25032350,   77.45779628,   48.33076593,  //mercury
                            0.72333566,    0.00677672,    3.39467605,   181.97909950,  131.60246718,   76.67984255,  //venus
                            1.00000261,    0.01671123,   -0.00001531,   100.46457166,  102.93768193,    0.0,         //earth moon bary
                            1.52371034,    0.09339410,    1.84969142,    -4.55343205,  -23.94362959,   49.55953891,  //mars
                            5.20288700,    0.04838624,    1.30439695,    34.39644051,   14.72847983,  100.47390909,  //jupiter
                            9.53667594,    0.05386179,    2.48599187,    49.95424423,   92.59887831,  113.66242448,  //saturn
                            19.18916464,   0.04725744,    0.77263783,   313.23810451,  170.95427630,   74.01692503,  //uranus
                            30.06992276,   0.00859048,    1.77004347,   -55.12002969,   44.96476227,  131.78422574,  //neptune/
                            39.48211675,   0.24882730,   17.14001206,   238.92903833,  224.06891629,  110.30393684 };//pluto
//                         AU/Cy         rad/Cy        deg/Cy        deg/Cy           deg/Cy       deg/Cy
static double _rates[]= {0.00000037,   0.00001906,  -0.00594749, 149472.67411175,   0.16047689,  -0.12534081,  //mercury
                         0.00000390,  -0.00004107,  -0.00078890,  58517.81538729,   0.00268329,  -0.27769418,  //venus
                         0.00000562,  -0.00004392,  -0.01294668,  35999.37244981,   0.32327364,   0.0,         //earth moon bary
                         0.00001847,   0.00007882,  -0.00813131,  19140.30268499,   0.44441088,  -0.29257343,  //mars
                        -0.00011607,  -0.00013253,  -0.00183714,   3034.74612775,   0.21252668,   0.20469106,  //jupiter
                        -0.00125060,  -0.00050991,   0.00193609,   1222.49362201,  -0.41897216,  -0.28867794,  //saturn
                        -0.00196176,  -0.00004397,  -0.00242939,    428.48202785,   0.40805281,   0.04240589,  //uranus
                         0.00026291,   0.00005105,   0.00035372,    218.45945325,  -0.32241464,  -0.00508664,  //neptune
                        -0.00031596,   0.00005170,   0.00004818,    145.20780515,  -0.04062942,  -0.01183482 };//pluto
//////////////////////////////
	// step 1
	// compute the value of each of that planet's six elements
	double a = _elements[6*planet+0] + _rates[6*planet+0]*time;	// (au) semi_major_axis
	double e = _elements[6*planet+1] + _rates[6*planet+1]*time;	//  ( ) eccentricity
	double I = _elements[6*planet+2] + _rates[6*planet+2]*time;	//  (°) inclination
	double L = _elements[6*planet+3] + _rates[6*planet+3]*time;	//  (°) mean_longitude
	double omega_bar = _elements[6*planet+4] + _rates[6*planet+4]*time;	//  (°) longitude_of_periapsis
	double OMEGA = _elements[6*planet+5] + _rates[6*planet+5]*time;	//  (°) longitude_of_the_ascending_node
	// step 2
	// compute the argument of perihelion, omega, and the mean anomaly, M
	double omega = omega_bar - OMEGA;
	double M = L - omega_bar;
	// step 3a
	// modulus the mean anomaly so that -180° ≤ M ≤ +180°
	while(M > 180) M-=360;  // in degrees
	// step 3b
	// obtain the eccentric anomaly, E, from the solution of Kepler's equation
	//   M = E - e*sinE
	//   where e* = 180/πe = 57.29578e
	double E = M + (e*180.0/PI) * sin(M*PI/180.0);  // E0
	for(int i = 0; i < 5; i++){  // iterate for precision, 10^(-6) degrees is sufficient
		E = KeplersEquation(E, M, e);
	}
	// step 4
	// compute the planet's heliocentric coordinates in its orbital plane, r', with the x'-axis aligned from the focus to the perihelion
	omega = omega * PI/180.0;
	E = E * PI/180.0;
	I = I * PI/180.0;
	OMEGA = OMEGA * PI/180.0;
	double x0 = a*(cos(E)-e);
	double y0 = a*sqrt((1.0-e*e))*sin(E);
	// step 5
	// compute the coordinates in the J2000 ecliptic plane, with the x-axis aligned toward the equinox:
	*planet_x = ( cos(omega)*cos(OMEGA) - sin(omega)*sin(OMEGA)*cos(I) )*x0 + ( -sin(omega)*cos(OMEGA) - cos(omega)*sin(OMEGA)*cos(I) )*y0;
	*planet_y = ( cos(omega)*sin(OMEGA) + sin(omega)*cos(OMEGA)*cos(I) )*x0 + ( -sin(omega)*sin(OMEGA) + cos(omega)*cos(OMEGA)*cos(I) )*y0;
	*planet_z = (			sin(omega)*sin(I)			 )*x0 + (			 cos(omega)*sin(I)			 )*y0;
}
