function dat = loadframe3Dcurvavg_nc4(filename)

narginchk(1,1)
%% SIMULATIONS RESULTS
dat.filename = filename;

%% Number densities
dat.ne = ncread(filename, 'neall');
%% Parallel Velocities
dat.v1 = ncread(filename, 'v1avgall');
%% Temperatures
dat.Ti = ncread(filename, 'Tavgall');
dat.Te = ncread(filename, 'TEall');
%% Current densities
dat.J1 = ncread(filename, 'J1all');
%  dat.J2 = permute(ncread(filename, 'J2all'), [1,3,2]);
%  dat.J3 = permute(ncread(filename, 'J3all'), [1,3,2]);
dat.J2 = ncread(filename, 'J2all');
dat.J3 = ncread(filename, 'J3all');
%% Perpendicular drifts
dat.v2 = ncread(filename, 'v2avgall');
dat.v3 = ncread(filename, 'v3avgall');
%% Topside potential
dat.Phitop = ncread(filename, 'Phiall');

end % function