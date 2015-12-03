function [ke] = elemstiff(node,x,y,gauss,therm,e);

% 2d QUAD element stiffness routine

ke = zeros(4,4);
one = ones(1,4);
psiJ = [-1, +1, +1, -1]; etaJ = [-1, -1, +1, +1];

% plane stress D matrix
D = therm*[1,0,;0,1]; %wikipedia aluminium
% fac = young(e)/(1 - (pr(e))^2);
% D = fac*[1.0, pr(e), 0;
%          pr(e), 1.0, 0.0;
%          0, 0, (1.-pr(e))/2 ];
      
% get coordinates of element nodes 
for j=1:4
   je = node(j,e); xe(j) = x(je); ye(j) = y(je);
end

% compute element stiffness
% loop over gauss points in eta
for i=1:2
   % loop over gauss points in psi
   for j=1:2
      eta = gauss(i);  psi = gauss(j);
      % compute derivatives of shape functions in reference coordinates
      NJpsi = 0.25*psiJ.*(one + eta*etaJ);
      NJeta = 0.25*etaJ.*(one + psi*psiJ);
      % compute derivatives of x and y wrt psi and eta
      xpsi = NJpsi*xe'; ypsi = NJpsi*ye'; xeta = NJeta*xe';  yeta = NJeta*ye';
      Jinv = [yeta, -ypsi; -xeta, xpsi];
      jcob = xpsi*yeta - xeta*ypsi;
      % compute derivatives of shape functions in element coordinates
      NJdpsieta = [NJpsi; NJeta];
      NJdxy = Jinv*NJdpsieta./jcob;
      % assemble B matrix
      BJ = zeros(2,4);
      BJ(1,1:4) = NJdxy(1,1:4);  BJ(2,1:4) = NJdxy(2,1:4);
      % assemble ke
      ke = ke + BJ'*D*BJ*jcob;
   end
end
