import numpy as np
from skfem import *
from skfem.helpers import dot, div

p = np.linspace(0, 1, 2)
m = MeshTri.init_tensor(p, p)
e = ElementTriRT0() * ElementTriP0()
basis = Basis(m, e)

@BilinearForm
def a(E, phi, tau, v, unused):
    return dot(E, tau) + div(E) * v + div(tau) * phi

@LinearForm
def L(tau, v, unused):
    return 0.0 * v

A = asm(a, basis)
b = asm(L, basis)
x = solve(A, b)
print(A.todense())
print(b)
(E, rt0basis), (phi, p0basis) = basis.split(x)
import matplotlib.pyplot as plt
plt.spy(A)
plt.show()
