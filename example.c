#include "kepler.h"
#include <stdio.h>

int main(){
	char *names[9] = {"Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"};
	double date = .138767; // mid November 2013
	printf("mid November 2013\n");
	double x, y, z;
	for(int i = 0; i < 9; i++){
		calculateLocationOfPlanet(i, date, &x, &y, &z);
		printf("%s\t%d°\t(x:%.3f  y:%.3f  z:%.3f)\n", names[i], (int)(atan2(y,x)/M_PI*180), x, y, z );
	}
	return 0;
}

/* the date is in J2000
 * the format of this number is: centuries after the year 2000
 * time = (year-2000)/100 + day_of_the_year/36525
 * where day_of_the_year would be 42 for February 11th.
*/