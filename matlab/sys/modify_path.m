function prepend = modify_path()
% for Octave on Windows, it's necessary to prepend MinGW path
% when running MinGW-compile exectuables
% Also, Matlab with Parallel Toolbox MPIEXEC conflicts with system MPIEXEC,
% so excise from Path
%
% a command is then run like
%
% system([prepend, ' ', 'foo.exe'])

prepend = '';
if isoctave && ispc && ~isempty(getenv('MINGWROOT'))

  syspath = [getenv('MINGWROOT'), pathsep, getenv('PATH')];
  % setenv('PATH', syspath)  % does not help
  prepend = ['set PATH=', syspath, ' && '];

elseif ~isoctave && ispc

  addons = matlab.addons.installedAddons();
  if ~any(contains(addons.Name, 'Parallel Computing Toolbox'))
    return
  end

  path_orig = split(getenv('PATH'), ';');
  i = contains(path_orig, 'MATLAB');  % Matlab's MPIexec will fail
  path_new = join(path_orig(~i), ';');

  % setenv('PATH', path_new{1}) % does not help
  prepend = ['set PATH=', path_new{1}, ' && '];

end  % if

end % function
