import numpy as np
from skfem import *
from skfem.helpers import dot, div

p = np.linspace(0, 1, 3)
m = MeshTri.init_tensor(p, p)
#m = MeshTri.init_sqsymmetric()#.refined().refined().refined()
e = ElementTriRT0() * ElementTriP0()
basis = Basis(m, e)

@BilinearForm
def a(E, phi, tau, v, unused):
    return dot(E, tau) + div(E) * v + div(tau) * phi

def f(x, y):
     return 2*np.pi*x * 2*np.pi*y

@LinearForm
def L(tau, v, w):
    return -1 * v

A = asm(a, basis)
b = asm(L, basis)
x = solve(A, b)
print("A: ")
print(m.nelements)
print(A.shape)
print(A[0:30, 30:].todense())

print("b: ")
print(b)

print("x: ")
print(x)

#print(sorted(A.data))

from scipy.io import savemat
savemat("dpy.mat", {"A":A, "b":b, "x":x, "n2c": m.p.T, "e2n": m.t.T})

solution = x[:-m.nvertices]
print(np.amax(solution))
(E, rt0basis), (phi, p0basis) = basis.split(x)
import matplotlib.pyplot as plt
plt.spy(A)
plt.show()
