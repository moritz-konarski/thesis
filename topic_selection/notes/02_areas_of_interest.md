# Areas of Interest

## Navier-Stokes Equations

- Newtonian -- shear force has no influence on viscosity
- Isothermal -- no thermal energy is lost or gained
- Incompressible -- trying to compress the fluid only increases the pressure
but the volume does not chage

### The Equations

$$\nabla \cdot \underline{u} = 0 \qquad \text{Mass is conserved}$$

- $\underline{u}$ is a vector in $(x,y,z)$, direction and speed of motion
- $\nabla$ is the differentiation of $\underline{u}$ is $\nabla \cdot 
\underline{u} = u_x + u_y + u_z$ -- divergence of the velocity
- basically just says that mass is conserved

$$\rho \frac{\partial \underline{u}}{\partial t} = - \nabla p + \mu \nabla^2
\underline{u} + \rho \underline{F} \qquad \text{Mass times acceleration = Force}$$

- Newton's second law $F = m \cdot a$ in diguise
- $\rho \frac{\partial \underline{u}}{\partial t}$ is the desity times the
acceleration, mass is density for fluids -- kinda
- the other side holds all the forces -- $- \nabla p + \mu \nabla^2 
\underline{u}$ are the internal forces, the ones between the particles, and
$\rho \underline{F}$ i are the external forces
- $\nabla p$ is the pressure gradient -- change in pressure, fluids tend to
move from points of high pressure to low pressure
- $\mu \nabla^2 \underline{u}$ is the viscosity -- sliding past one another
creates friction

### The Problem

- the equations work, they have been around for a long time
- we simply don't know if they have a solution and we don't necessarily
understand if they will have solution or not -- mathematical understanding is
still behind the applications
    1. Solution must exist -- there has to be a way to find one
    2. Solution must be unique -- there has to be only one way to solve an
       equation given a certain initial state
    3. Solution must be smooth -- small changes in the input must only cause
       small changes in the output
- making assumptions about the process makes it simpler to actually use the
equations
- taking averages over certain areas can also make the application simpler
- for the Clay Millennium problems -- for 3D there are some solutions we can
find -- slow initial velocities, finite time, averaging, just not for all the
conditions
- turbulence is one of the most annoying facets of navier-stokes equations
- practical usage is great, mathematically speaking we don't understand them

### Possible Topics

- flow around a right-angle corner where there is a singularity at the inner
point, velocity is infinite
- 

### Reynold's Number

$$\text{Re} = \frac{\rho \cdot L \cdot U}{\mu}$$ 

density, length scale, velocity divided by viscosity

- when Reynold's Number is high or low, the same fluid moves differently
- these numbers are generally really low or really high -- low means ~10, high
means ~10.000
- turbulence means $\text{Re} > 1.000} 
- if $\text{Re} >> 1$, the second formula becomes 

$$ \frac{\partial \underline{u}}{\partial t} = -\nabla p + \frac{1}{\text{Re}} 
\mu \nabla^2 \underline{u}$$

- the system is not non-dimensionalized -- all the unites are gone
- this is anything with turbulence, like air moving around stuff
- now there are no units and all things can now be compared
- if one number is bigger than the other, it has more influence and counts more
- for large Re the viscosity does not matter
- for $\text{Re} << 1$, the second formula becomes

$$ \text{Re} \frac{\partial \underline{u}}{\partial t} = -\nabla p + \nabla^2 
\underline{u}$$

- in this case the non-linear component is lost, this make is super easy to
solve (comparably at least)
- in this case the acceleration does not matter because Re is really small
- now time is no longer in our equations -- this means equations are reversible
- very high viscosity can do this -- honey and most types of syrups

### Where does river water go when it hits the ocean?

- does the river turn right (North) or left (Southern) or straight (Equator)
- two features, whirlpool where the water enters, then flow to the right 
- what is the width, speed, depth of the river

### The Papers

1. Numerical Solution of the Navier-Stokes Equations, A. J. Chorin,
<http://www.jstor.com/stable/2004575>
    - numerical solutions to n-s equations
    - Bernard convection
    - incompressible flow
    - time-dependent
2. Instability Theory of the Navier-Stokes-Poisson Equations, J. Jang & I.
Tice, <https://dx.doi.org/10.2140/apde.2013.6.1121>
    - Lane-Emden stationary gaseous star configurations
    - linear and non-linear dynamical instability results
    - Navier-Stokes-Poisson -- hydrodynamical model of a star
3. Localization and Compactness properties of the Navier-Stokes global
regularity problem, T. Tao, <https://dx.doi.org/10.2140/apde.2013.6.25>
    - global regularity problem
    - localized energy and entropy estimates of the Navier-Stokes equations
4. Embedded Boundary Method for the Navier-Stokes Equations on
a time-dependent domain, G. H. Miller & D. Trebotich, COMM. APP. MATH. 
AND COMP. SCI. Vol. 7, No. 1, 2012
    - flow simulation of incompressible Navier-Stokes equations

## Compression and Decompression Algorithms

1. Lossless Astronomical Image Compression and the Effects of Noise, W. D.
Pence, R. Seaman, & R. L. White,
<https://www.jstor.org/stable/10.1086/599023>
    - evaluation of lossless compression techniques 
    - compression efficiency
    - noise in picture
    - average number of bits of noise for each pixel value
    - synthetic picture then analysed
2. Epsilon Entropy and Data Compression, E. C. Posner, E. R. Rodemich,
<http://www.jstor.com/stable/2240137>
    - epsilon entropy -- now much data is needed for good description to
    within $\epsilon$
3. Vision and the Coding of Natural Images: brain secrets to image
compression, B. A. Olshausen, D. J. Field,
<http://www.jstor.com/stable/27858027>
    - using neuroscience to investigate how animals and nature encode and
    compress images
    - understand and then copy how humans recognize shapes and objects
4. Data Compression: Something for Nothing, J. MacCormick,
<http://www.jstor.com/stable/j.ctt7t71s.10>
    - history and basics of compression algorithm
5. Data Compression, C. C. McGeoch, <https://www.jstor.org/stable/2324310>
    - short basics of computer science
6. Fast Sinc transform and image reconstruction from nonuniform samples in
k-space, L. Greengard, J.-Y. Lee, & S. Inati, COMM. APP. MATH. AND COMP. 
SCI. Vol. 1, No. 1, 2006
    - sinc transform is a solution in image reconstruction, image
    processing, it's precise but slow
    - here is the fast sinc transform that performs convolution on data in
    $O(N \log N)$ for $N$ data points

## Maxwell's Equations

1. Real-Space Green's Function Method for the numerical solution of
Maxwell's Equations, B. Lo, V. Minden, & P. Colella,
<https://dx.doi.org/10.2140/camcos.2016.11.143>
    - free-space Maxwell equations in 3D
    - Helmholtz decomposition
    - Duhamel's formula

## Computer Science

1. Algorithm of traffic signs recognition based on the rapid transform, J.
Gamec, D. Urdzik, & M. Gamcova, DOI: 10.2478/s13537-012-0019-3
    - 5 stage model to recognize traffic signs
