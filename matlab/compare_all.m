function compare_all(outdir, refdir, only)
% compare entire output directory data files, and input files
%
% absolute and relative tolerance account for slight IEEE-754 based differences,
% including non-associative, non-commutative floating-point arithmetic.
% these parameters are a bit arbitrary.

% per MZ Oct 17, 2018:
% Ti,Te=1 K
% ne=1e6 m-3
% vi,v2,v3=1 m/s
% J1,J2,J3 = 1e-9

% MZ wants to change what we consider signficant...
% Ti,Te=5 K
% ne=1e7 m-3
% vi,v2,v3=2 m/s
% J1,J2,J3 = 1e-9

narginchk(2,3)

if nargin < 3, only = []; end

addpath(fullfile(fileparts(mfilename('fullpath')), 'vis'))

tol.rtol = 1e-5;
tol.rtolN = 1e-5;
tol.rtolT = 1e-5;
tol.rtolJ = 1e-5;
tol.rtolV = 1e-5;
tol.atol = 1e-8;
tol.atolN = 1e9;
tol.atolT = 100;
tol.atolJ = 1e-7;
tol.atolV = 50;

outdir = absolute_path(outdir);
refdir = absolute_path(refdir);

exist_or_skip(outdir, 'dir')
exist_or_skip(refdir, 'dir')
%% check that paths not the same
if strcmp(outdir, refdir)
  error('compare_all:value_error', '%s and %s directories are the same', outdir, refdir)
end
%% times

%% check output dirs
out_ok = 0;
if isempty(only) || any(strcmp(only, 'out'))
  out_ok = compare_output(outdir, refdir, tol);
end
%% check input dirs
in_ok = 0;
if isempty(only) || any(strcmp(only, 'in'))
  in_ok = compare_input(outdir, refdir, tol);
end
%% finish up
if out_ok ~= 0 || in_ok ~= 0
  error('compare_all:value_error', '%d output, %d input: compare errors', out_ok, in_ok)
end

end % function


function ok = compare_output(outdir, refdir, tol)

narginchk(3,3)
%% READ IN THE SIMULATION INFORMATION
params = read_config(outdir);

lxs = simsize(outdir);
lxs_ref = simsize(refdir);
if any(lxs ~= lxs_ref)
  error('compare_all:value_error', ['ref dims ', int2str(lxs_ref), ' != this sim dims ', int2str(lxs)])
end

disp(['sim grid dimensions: ',num2str(lxs)])

UTsec = params.UTsec0:params.dtout:params.UTsec0 + params.tdur;
ymd = params.ymd;
Nt = length(UTsec);

ok = 0;

for i = 1:Nt
  st = ['UTsec ', num2str(UTsec(i))];
  out = loadframe(outdir,ymd,UTsec(i));
  ref = loadframe(refdir,ymd,UTsec(i));

  ok = ok + ~assert_allclose(out.ne,ref.ne,tol.rtolN,tol.atolN,['Ne ',st], true);

  if false
    ok = ok + ~assert_allclose(out.v1,ref.v1,tol.rtolV,tol.atolV,['V1 ', st], true);
  end
  ok = ok + ~assert_allclose(out.v2,ref.v2,tol.rtolV,tol.atolV,['V2 ', st], true);
  ok = ok + ~assert_allclose(out.v3,ref.v3,tol.rtolV,tol.atolV,['V3 ', st], true);

  if false
    ok = ok + ~assert_allclose(out.Ti,ref.Ti,tol.rtolT,tol.atolT,['Ti ', st], true);
  end
  ok = ok + ~assert_allclose(out.Te,ref.Te,tol.rtolT,tol.atolT,['Te ', st], true);

  ok = ok + ~assert_allclose(out.J1,ref.J1,tol.rtolJ,tol.atolJ,['J1 ', st], true);
  ok = ok + ~assert_allclose(out.J2,ref.J2,tol.rtolJ,tol.atolJ,['J2 ', st], true);
  ok = ok + ~assert_allclose(out.J3,ref.J3,tol.rtolJ,tol.atolJ,['J3 ', st], true);

  %% assert time steps have unique output (earth always rotating...)
  if i > 1
    ok = ok + ~assert_allclose(Ne,out.ne,tol.rtol,tol.atol,['Ne ', st,' too similar to prior step'],true, true);
    %ok = ok + ~assert_allclose(v1,out.v1,tol.rtol,tol.atol,['V1 ', st,' too similar to prior step'],true, true);
    ok = ok + ~assert_allclose(v2,out.v2,tol.rtol,tol.atol,['V2 ', st,' too similar to prior step'],true, true);
    ok = ok + ~assert_allclose(v3,out.v3,tol.rtol,tol.atol,['V3 ', st,' too similar to prior step'],true, true);
  end
  if i == 3
   %ok = ok + ~assert_allclose(Ti,out.Ti,tol.rtol,tol.atol,['Ti ', st,' too similar to prior step'],true, true);
    ok = ok + ~assert_allclose(Te,out.Te,tol.rtol,tol.atol,['Te ', st,' too similar to prior step'],true, true);
  end
  if i == 2
    ok = ok + ~assert_allclose(J1,out.J1,tol.rtol,tol.atol,['J1 ', st,' too similar to prior step'],true,true, true);
    ok = ok + ~assert_allclose(J2,out.J2,tol.rtol,tol.atol,['J2 ', st,' too similar to prior step'],true,true, true);
    ok = ok + ~assert_allclose(J3,out.J3,tol.rtol,tol.atol,['J3 ', st,' too similar to prior step'],true,true, true);
  end

  Ne = out.ne;
  v1=out.v1; v2=out.v2; v3=out.v3;
  Ti=out.Ti; Te=out.Te;
  J1=out.J1; J2=out.J2; J3=out.J3;

end % for

if ok == 0
  fprintf('OK: Gemini output comparison of %d time steps.\n', Nt)
end

end % function compare_output

function ok = compare_input(outdir, refdir, tol)
narginchk(3,3)

ref_params = read_config(refdir);
ref_indir = fullfile(refdir, 'inputs');
[~, ref_name, ref_ext] = fileparts(ref_params.indat_file);
ref = loadframe3Dcurvnoelec(fullfile(ref_indir, [ref_name, ref_ext]));

new_params = read_config(outdir);
new_indir = fullfile(outdir, 'inputs');
[~, new_name, new_ext] = fileparts(ref_params.indat_file);
new = loadframe3Dcurvnoelec(fullfile(new_indir, [new_name, new_ext]));

ok = 0;

ok = ok + ~assert_allclose(new.ns, ref.ns, tol.rtol, tol.atol, 'Ns', true);
ok = ok + ~assert_allclose(new.Ts, ref.Ts, tol.rtol, tol.atol, 'Ts', true);
ok = ok + ~assert_allclose(new.vs1, ref.vs1, tol.rtol, tol.atol, 'vs', true);

UTsec = new_params.UTsec0:new_params.dtout:new_params.UTsec0 + new_params.tdur;
ymd = new_params.ymd;
Nt = length(UTsec);

%% precipitation
prec_errs = 0;
[~, name, ext] = fileparts(new_params.prec_dir);
prec_path = fullfile(new_indir, [name, ext]);

[~, name, ext] = fileparts(ref_params.prec_dir);
ref_prec_path = fullfile(ref_indir, [name, ext]);

if is_folder(prec_path)
  % often we reuse precipitation inputs without copying over files
  for i = 1:Nt
    st = ['UTsec ', num2str(UTsec(i))];
    ref = load_precip(get_frame_filename(ref_prec_path, ymd, UTsec(i)));
    new = load_precip(get_frame_filename(prec_path, ymd, UTsec(i)));

    for k = {'E0', 'Q'}
      b = ref.(k{:});
      a = new.(k{:});

      if all(size(a) ~= size(b))
        error("compare_all:value_error", "%s: ref shape {b.shape} != data shape {a.shape}", k{:})
      end

      if ~allclose(a, b, tol.rtol, tol.atol)
        prec_errs = prec_errs + 1;
        fprintf(2, "mismatch: %s %s\n", k{:}, st)
      end
    end
  end

  ok = ok + prec_errs;

else
  fprintf(2, "SKIP: precipitation %s \n", prec_path)
end
if ok == 0
  disp('OK: Gemini input comparison')
end

end % function compare_input

% Copyright 2020 Michael Hirsch, Ph.D.

% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at

%     http://www.apache.org/licenses/LICENSE-2.0

% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
