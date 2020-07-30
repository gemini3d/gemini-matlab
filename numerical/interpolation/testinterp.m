function testinterp(fn)

narginchk(1,1)

exist_or_skip(fn, 'file')

if isoctave
  h = load(fn);
  lx1 = h.lx1;
  lx2 = h.lx2;
  x1 = h.x1;
  x2 = h.x2;
  f = h.f;
else
  lx1 = h5read(fn, '/lx1');
  lx2 = h5read(fn, '/lx2');
  x1 = h5read(fn, '/x1');
  x2 = h5read(fn, '/x2');
  f = h5read(fn, '/f');
end

assert(lx1==500, 'x1 size')
assert(lx2==1000, 'x2 size')
assert(all(size(f) == [lx1,lx2]), 'array size mismatch')

if ~isinteractive
  return
end
%% PLOT
hf = figure;
ax = axes('parent', hf);

if (lx2==1)
  plot(ax, x1,f);
  xlabel(ax, 'x_1')
  ylabel(ax, 'f')
  title(ax, '1-D interp')
else
  imagesc(x2,x1,f, 'parent', ax);
  axis(ax, 'xy')
  xlabel(ax, 'x_2')
  ylabel(ax, 'x_1')
  c=colorbar('peer', ax);
  ylabel(c,'f')
  title(ax, '2-D interp')
end
%print -dpng -r300 ~/testinterp.png;

end % function
