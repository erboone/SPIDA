import subprocess as sub

zs = [1500, 3000, 4500, 6000, 7500]
lambdas = [405, 488, 560, 650, 750]

from itertools import product

for z, lam in product(zs, lambdas):
    sub.run(
        f"dw_bw --resxy 100 --resz {z} --lambda {lam} --NA 1.4 --ni 1.518 psf_folder/{lam}_z{z}_psf.tiff"\
        .split()
        )