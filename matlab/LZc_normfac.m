function [cm,cv] = LZc_normfac(n,a,ver,asymp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LZc normalisation factors.
%
% If 'asymp' is false (default), then returns means and (optionally) variances of LZc
% for random sequences with the supplied lengths and alphabet size from data files, as
% available. Binary normalisation data may be downloaded from:
%
%    http://users.sussex.ac.uk/~lionelb/downloads/fLZc_data.zip
%
% and should be unzipped into fLZc_data_path (see startup.m). If requested values are
% not available, NaNs are returned.
%
% If 'asymp' is true, then returns theoretical asymptotic upper bound values in cm (not
% recommended for short sequences).
%
% INPUT
%
% n        vector of sequence lengths
% a        alphabet size
% ver      LZc version: 76 or 78
% asymp    flag for asymptotic vs. random normalisation (default: false)
%
% OUTPUT
%
% cm       random sequence mean LZc (or theoretical ceilings if asymp = false)
% cv       random sequence variances, if available
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

assert(isvector(n) && isnumeric(n) && all(n == floor(n)) && all(n > 0),'String lengths must be a vector of positive integers');
assert(isscalar(a) && isnumeric(a) && a == floor(a)  && a > 1,'Alphabet size must be an integer > 1');
assert(ver == 76 || ver == 78,'Lempel-Ziv version must be 76 or 78');

if nargin < 4 || isempty(asymp), asymp = false; end % default: use random data files

if asymp
	error('Sorry, asymptotic bounds not currently implemented (and actually not that great for normalisation anyway)');
end

global fLZc_data_path;
cmean = [];
cvar  = [];
fname = fullfile(fLZc_data_path,sprintf('LZ%dc_rand_a%02d.mat',ver,a));
try
	load(fname);
catch
	error('\n\t*** No data found for alphabet size %d ***',a);
end

% loaded:
%
% nmax   : max string length
% asize  : alphabet size
% nsamps : number of samples used for estimates
% rseed  : random seed
% cmean  : means     at each string length 1 ... nmax
% cvar   : (optionally) variances at each string length 1 ... nmax

iof = find(n <= nmax); % indices on file
nof = n(iof);          % values on file

numn = length(n);

cm = nan(numn,1);
cm(iof) = cmean(nof);

if nargout > 1
	assert(~isempty(cvar),'Sorry, ''%s'' does not contain variances',fname);
	cv = nan(numn,1);
	cv(iof) = cvar(nof);
end
