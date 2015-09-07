# SLLGPLVM
Matlab Code for Supervised Latent Linear Gaussian Process Latent Variable Model for Dimensionality Reduction (SLLGPLVM)


My code is based on old version of Neil Lawrence's GPLVM code(http://staffwww.dcs.shef.ac.uk/people/N.Lawrence/fgplvm/) and C. K. I. Williams's multiple-class GP classification code(http://www.dai.ed.ac.uk/homes/ckiw/code/gpclass.tar.gz) . For the consideration of compatibility, I have used and kept their codes in my project. Thanks. 


Reference:

Xinwei Jiang, Junbin Gao, Tianjiang Wang, Lihong Zheng. Supervised Latent Linear Gaussian Process Latent Variable Model for Dimensionality Reduction.  IEEE Transactions on Systems, Man, and Cybernetics, Part B. Vol. 42(6): 1620-1632. 2012. 


Experimental Settings:

1. Enter directory \SGPC;
2. Run setdir.m to set paths;
3. Run demos like demSllgplvmOilFT150, demSllgplvmUSPS5And3DC, demSllgplvm1VsRestOilNC


Notes:

For the multiple-class tasks, there are two options: 

1. you can use function MultiSllgplvm(...) based on C. K. I. Williams's multiple-class GP classification code, 
2. or you can use function MultiSllgplvm1VsRest(...) based on one versus rest scheme. 

However, for visulization, you have to make use of MultiSllgplvm(...), because function MultiSllgplvm1VsRest(...) do not return the result of latent variables but the classification accuracy.


Drop me emails if there are questions or bugs for this paper or code.

Homepage: http://www.xwjiang.com
Email: ysjxw@hotmail.com
