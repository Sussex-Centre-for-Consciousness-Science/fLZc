function [s,qtiles] = LZc_quantise(x,q,use_qtiles,numsym)

% Quantise data sequence x (column vector) into q quantiles (so number of symbols = q+1).
%
% q = 0 is allowed, if trivial (yields constant string on 1 symbol).
%
% If q is a vector, then don't do actual quantiles: instead, q(k) = k-th quantisation level.
%
% s returns the quantised symbol string, qtiles the quantisation levels used (normally quantiles).

if nargin < 3 || isempty(use_qtiles), use_qtiles = true; end % default: calculate quantiles
if nargin < 4 || isempty(numsym),     numsym     = true; end % default: numeric symbols

assert(iscolumn(x),'Input must be a column vector');
n = length(x);

if use_qtiles
	assert(isnumeric(q) && q == floor(q) && q >= 0,'Number of quantiles must be a non-negative integer');
	if q == 0
		qtiles = nan;
		s = char(48+zeros(1,n));
	elseif q == 1
		qtiles = median(x); % do the right thing (because of strange behaviour of 'quantile' for q = 1)
	else
		qtiles = quantile(x,q);
	end
else
	assert(isnumeric(q) && isvector(q),'Quantisation levels must be a numeric vector');
	qtiles = q;
end
nqtiles = length(qtiles);

% Quantise

z = zeros(1,n);
Q = [-Inf qtiles Inf]; % +/- Inf does the right thing!
for k = 1:nqtiles+1
	z(Q(k) < x & x <= Q(k+1)) = k-1;
end

if numsym
	s = char(48+z); % '0', '1', '2', ...
else
	s = char(97+z); % 'a', 'b', 'c', ...
end
