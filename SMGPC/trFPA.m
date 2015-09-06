function t = trFPA(FP,A,nn,m)

t=0;
for c = 1:m
  d = diag(FP(1+(c-1)*nn:c*nn,1:nn));
  fe = A(1+(c-1)*nn:c*nn,1);
  t = t + d'*fe;
end
end
