% 2d QUAD biquadratic element stiffness routine

function [ke] = elemstiff_biquadratic(node,x,y,gauss,therm,e);

ke = zeros(9,9);

% plane conductivity D matrix
D = therm*[1,0;0,1]; %wikipedia aluminium
      
% get coordinates of element nodes 
for j=1:9
   je = node(j,e); xe(j) = x(je); ye(j) = y(je);
end

% compute element stiffness
% loop over gauss points in eta
for i=1:2
   % loop over gauss points in psi
   for j=1:2
      eta = gauss(i);  psi = gauss(j);
      % compute derivatives of shape functions in reference coordinates
      NJpsi = [(psi-1/2)*(1/2*(eta^2-eta)) ...
          (psi+1/2)*(1/2*(eta^2-eta)) ...
          (psi+1/2)*(1/2*(eta^2+eta)) ...
          (psi-1/2)*(1/2*(eta^2+eta)) ...
          (-2*psi)*(1/2*(eta^2-eta)) ...
          (psi+1/2)*(1-eta^2) ...
          (-2*psi)*(1/2*(eta^2+eta)) ...
          (psi-1/2)*(1-eta^2) ...
          (-2*psi)*(1-eta^2)];
      NJeta = [(1/2*(psi^2-psi))*(eta-1/2) ...
          (1/2*(psi^2+psi))*(eta-1/2) ...
          (1/2*(psi^2+psi))*(eta+1/2) ...
          (1/2*(psi^2-psi))*(eta+1/2) ...
          (1-psi^2)*(eta-1/2) ...
          (1/2*(psi^2+psi))*(-2*eta) ...
          (1-psi^2)*(eta+1/2) ...
          (1/2*(psi^2-psi))*(-2*eta) ...
          (1-psi^2)*(-2*eta)];
      % compute derivatives of x and y wrt psi and eta
      xpsi = NJpsi*xe'; ypsi = NJpsi*ye'; xeta = NJeta*xe';  yeta = NJeta*ye';
      Jinv = [yeta, -ypsi; -xeta, xpsi];
      jcob = xpsi*yeta - xeta*ypsi;
      % compute derivatives of shape functions in element coordinates
      NJdpsieta = [NJpsi; NJeta];
      NJdxy = Jinv*NJdpsieta./jcob;
      % assemble B matrix
      BJ = zeros(2,9);
      BJ(1,1:9) = NJdxy(1,1:9);  BJ(2,1:9) = NJdxy(2,1:9);
      % assemble ke
      ke = ke + BJ'*D*BJ.*jcob;
   end
end