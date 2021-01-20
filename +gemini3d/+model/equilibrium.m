function xg = equilibrium(cfg)
%% setup equilibrium simulation

arguments
  cfg (1,1) struct
end
%% GRID GENERATION
xg = gemini3d.grid.cart3d(cfg);

gemini3d.write.grid(cfg, xg);

%% Equilibrium input generation

ics = gemini3d.model.eqICs(cfg, xg);
% Note: should be rewritten to include the neutral module form the fortran code
gemini3d.write.state(cfg.indat_file, ics, cfg.file_format);

end % function
