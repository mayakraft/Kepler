// Keplerian Elements for Approximate Positions of the Major Planets
// 
// Lower accuracy formulae for planetary positions have a number of important applications when one doesn't
// need the full accuracy of an integrated ephemeris. They are often used in observation scheduling, telescope
// pointing, and prediction of certain phenomena as well as in the planning and design of spacecraft missions.
//
// NOTE: this implementation is valid for the time interval 1800 AD - 2050 AD, but will run outside these times

int WIDTH = 512;
int HEIGHT = 768;
int centerX1 = (int)(WIDTH*.5);
int centerY1 = (int)(WIDTH*.5);
int centerX2 = (int)(WIDTH*.5);
int centerY2 = (int)(WIDTH*1.25);

// some quick colors grabbed from pictures of planets
static int colors[] = {192,192,192,206,172,113,0,19,174,172,81,40,186,130,83,253,196,126,149,188,198,98,119,226,192,192,192};
// planet coordinates in the J2000 ecliptic plane
float[] planetsX = new float[9];
float[] planetsY = new float[9];
float[] planetsZ = new float[9];
int[] zindex = {0,1,2,3,4,5,6,7,8};  // for screen draw order
// mouse
int speed = 0;  // for mouse click. it's really a boolean, fast or slow
float ZOOM = 86.0;   // initial zoom fits the 4 inner terrestrial planets
int SIZE = (int)( (pow(ZOOM,.333)*4) );   // planet/sun size

// the format of this number is: centuries after the year 2000
float time = .138767; // mid November 2013
// time = (year-2000)/100 + day_of_the_year/36525
// where day_of_the_year would be 42 for February 11th.

boolean animate = true;   // turn on animation. time moves quickly

void setup(){
  size(WIDTH,HEIGHT);
  stroke(0);
  strokeWeight(0); 
  fill(255);  
}

void draw(){
  // fill up the table of planet locations: X, Y, Z
  for(int i = 0; i < 9; i++){
    double position[] = calculateLocationOfPlanet(i, time);
    planetsX[i] = (float)position[0];
    planetsY[i] = (float)position[1];
    planetsZ[i] = (float)position[2];
  }
  sortZIndexes();
  
  // draw
  background(255);
  strokeWeight(1); 
  line(0,WIDTH,WIDTH,WIDTH);
  strokeWeight(SIZE*.1);
  fill(0);
  int year = (int)(time*100.0+2000);
  textSize(32);
  text(year, 10, 30); 

  boolean sun = false;
  for(int i = 8; i >= 0; i--){
    // draw the sun at appropriate z index
    if(planetsY[zindex[i]] > 0 && !sun){
      fill(242,229,129);
      ellipse(centerX1, centerY1, SIZE, SIZE);
      ellipse(centerX2, centerY2, SIZE, SIZE);
      sun = true;
    }
    fill(colors[3*zindex[i]+0],colors[3*zindex[i]+1],colors[3*zindex[i]+2]);
    if(centerX1 + planetsY[zindex[i]]*ZOOM < WIDTH)  // prevent overlap from the 1st screen to the 2nd
      ellipse(centerX1 + planetsX[zindex[i]]*ZOOM, centerY1 + planetsY[zindex[i]]*ZOOM, SIZE, SIZE);
    ellipse(centerX2 + planetsX[zindex[i]]*ZOOM, centerY2 + planetsZ[zindex[i]]*ZOOM, SIZE, SIZE);
  }
  if(animate)
    time = time + .00001 + .00175*speed;
}

void sortZIndexes(){
  double farthest;
  double lastFarthest = 10000.;
  int farthestIndex = 0;
  for(int j = 0; j < 9; j++){
    farthest = -1000;
    for(int i = 0; i < 9; i++){
      if(planetsY[i] > farthest && planetsY[i] < lastFarthest){
        farthest = planetsY[i];
        farthestIndex = i;
      }
    }
    lastFarthest = farthest;
    zindex[j] = farthestIndex;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getAmount();
  ZOOM = ZOOM * pow(2,(e)/100.0);
  if(ZOOM < 5.5) ZOOM = 5.5;
  else if (ZOOM > 2000.0) ZOOM = 2000.0;
  SIZE = (int)( (pow(ZOOM,.333)*4) );
}

void mouseClicked(){
  if(speed == 0) speed = 1;
  else speed = 0;
}

// Planet locations in reference to the J2000 ecliptic plane, with the X-axis aligned toward the equinox
//
// reference:
// http://ssd.jpl.nasa.gov/txt/aprx_pos_planets.pdf
//    - even more information at http://iau-comm4.jpl.nasa.gov/XSChap8.pdf
//
// Robby Kraft
//                               a                e                I                 L            long.peri.       long.node.
//                              AU               rad              deg               deg              deg              deg
static double elements[] = {0.38709927,      0.20563593,      7.00497902,      252.25032350,     77.45779628,     48.33076593,  //mercury
                            0.72333566,      0.00677672,      3.39467605,      181.97909950,    131.60246718,     76.67984255,  //venus
                            1.00000261,      0.01671123,     -0.00001531,      100.46457166,    102.93768193,      0.0,         //earth moon barycenter
                            1.52371034,      0.09339410,      1.84969142,       -4.55343205,    -23.94362959,     49.55953891,  //mars
                            5.20288700,      0.04838624,      1.30439695,       34.39644051,     14.72847983,    100.47390909,  //jupiter
                            9.53667594,      0.05386179,      2.48599187,       49.95424423,     92.59887831,    113.66242448,  //saturn
                            19.18916464,      0.04725744,      0.77263783,      313.23810451,    170.95427630,     74.01692503, //uranus
                            30.06992276,      0.00859048,      1.77004347,      -55.12002969,     44.96476227,    131.78422574, //neptune
                            39.48211675,      0.24882730,     17.14001206,      238.92903833,    224.06891629,    110.30393684 };//pluto
//                         AU/Cy           rad/Cy           deg/Cy           deg/Cy              deg/Cy           deg/Cy
static double rates[] = {0.00000037,      0.00001906,     -0.00594749,   149472.67411175,      0.16047689,     -0.12534081,  //mercury
                         0.00000390,     -0.00004107,     -0.00078890,    58517.81538729,      0.00268329,     -0.27769418,  //venus
                         0.00000562,     -0.00004392,     -0.01294668,    35999.37244981,      0.32327364,      0.0,         //earth moon barycenter
                         0.00001847,      0.00007882,     -0.00813131,    19140.30268499,      0.44441088,     -0.29257343,  //mars
                        -0.00011607,     -0.00013253,     -0.00183714,     3034.74612775,      0.21252668,      0.20469106, //jupiter
                        -0.00125060,     -0.00050991,      0.00193609,     1222.49362201,     -0.41897216,     -0.28867794, //saturn
                        -0.00196176,     -0.00004397,     -0.00242939,      428.48202785,      0.40805281,      0.04240589, //uranus
                         0.00026291,      0.00005105,      0.00035372,      218.45945325,     -0.32241464,     -0.00508664,  //neptune
                        -0.00031596,      0.00005170,      0.00004818,      145.20780515,     -0.04062942,     -0.01183482 };//pluto

double KeplersEquation(double E, double M, double e)
{
  double deltaM = M - ( E - (e*180./PI) * sin((float)E*PI/180.) );
  double deltaE = deltaM / (1 - e*cos((float)E*PI/180.));
  return E + deltaE;
}

double[] calculateLocationOfPlanet(int planet, float time)
{
    double ecliptic[] = new double[3];
    // step 1
    // compute the value of each of that planet's six elements
    double a = elements[6*planet+0] + rates[6*planet+0]*time;    // (au) semi_major_axis
    double e = elements[6*planet+1] + rates[6*planet+1]*time;    //  ( ) eccentricity
    double I = elements[6*planet+2] + rates[6*planet+2]*time;    //  (°) inclination
    double L = elements[6*planet+3] + rates[6*planet+3]*time;    //  (°) mean_longitude
    double omega_bar = elements[6*planet+4] + rates[6*planet+4]*time;    //  (°) longitude_of_periapsis
    double OMEGA = elements[6*planet+5] + rates[6*planet+5]*time;    //  (°) longitude_of_the_ascending_node
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
    double E = M + (e*180./PI) * sin((float)M*PI/180.);  // E0
    for(int i = 0; i < 5; i++){  // iterate for precision, 10^(-6) degrees is sufficient
        E = KeplersEquation(E, M, e);
    }
    // step 4
    // compute the planet's heliocentric coordinates in its orbital plane, r', with the x'-axis aligned from the focus to the perihelion
    omega = omega * PI/180.;
    E = E * PI/180.;
    I = I * PI/180.;
    OMEGA = OMEGA * PI/180.;
    double x0 = a*(cos((float)E)-e);
    double y0 = a*sqrt((float)(1-e*e))*sin((float)E);
    // step 5
    // compute the coordinates in the J2000 ecliptic plane, with the x-axis aligned toward the equinox:
    ecliptic[0] = ( cos((float)omega)*cos((float)OMEGA) - sin((float)omega)*sin((float)OMEGA)*cos((float)I) )*x0 + ( -sin((float)omega)*cos((float)OMEGA) - cos((float)omega)*sin((float)OMEGA)*cos((float)I) )*y0;
    ecliptic[1] = ( cos((float)omega)*sin((float)OMEGA) + sin((float)omega)*cos((float)OMEGA)*cos((float)I) )*x0 + ( -sin((float)omega)*sin((float)OMEGA) + cos((float)omega)*cos((float)OMEGA)*cos((float)I) )*y0;
    ecliptic[2] = (            sin((float)omega)*sin((float)I)             )*x0 + (             cos((float)omega)*sin((float)I)             )*y0;
    return ecliptic;
}
