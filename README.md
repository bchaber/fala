<p align="center">
  <img src="https://github.com/bchaber/fala/blob/main/logo.svg" width="256px" alt="A simple RLC circuit connected to form an equilateral triangle (or Laplace operator Δ = ∇² as in wave equation)"/>
  <h1>fala</h1>
</p>

fala is a Whitney element based, structured finite element method for electromagnetic simulations coupled with electrical circuits.

# origin
The foundation of the implementation of Whitney elements comes from two sources:
- David B. Davidson, Computational Electromagnetics for RF and Microwave Engineering, 2nd edition, 2010, Cambridge University Press;
- Thomas Rylander, Pär Ingelström, and Anders Bondeson, Computational Electromagnetics, 2013, Springer-Verlag New York.

Davidson's MATLAB code has helped implementing rectangular edge elements and served as a test case scenario.
The MATLAB code from Rylander et al. improved the implementation of triangular edge elements.

Since then, both codes has been mashed together and repurposed as a time-domain electromagnetic field solvers on structured grids.

# features
The wave equation can be coupled with an external, nonlinear circuit using the idea from [1].

[1] M. Feliziani and F. Maradei, "Circuit-oriented FEM: solution of circuit-field coupled problems by circuit equations," in IEEE Transactions on Magnetics, vol. 38, no. 2, pp. 965-968, March 2002, doi: 10.1109/20.996248.

# running
(coming soon)

# test cases
(coming soon)
