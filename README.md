Keplerian Elements 
======
###for Approximate Positions of the Major Planets

"Lower accuracy formulae for planetary positions have a number of important applications when one doesn't need the full accuracy of an integrated ephemeris. They are often used in observation scheduling, telescope pointing, and prediction of certain phenomena **as well as in the planning and design of spacecraft missions**."

positions valid for 1800 AD - 2050 AD

```JAVA
double[] calculateLocationOfPlanet(int planet, float time)
```

returns an array `double, double, double` for X, Y, Z position in the J2000 ecliptic plane with the equinox aligned to the X axis.

`int planet` 0=Mercury 1=Venus 2=Earth/Moon Barycenter… 7=Neptune

`float time` in centuries after the year 2000. 

###Mouse
* scroll to zoom
* click to switch between slow/fast

***

NASA JPL (sec 8.10): [http://iau-comm4.jpl.nasa.gov/XSChap8.pdf](http://iau-comm4.jpl.nasa.gov/XSChap8.pdf)
