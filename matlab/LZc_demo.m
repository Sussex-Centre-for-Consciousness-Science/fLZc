% LZc demo script: generate an (approximate) Ornstein Uhlenbeck time series, and calculate
% normalised LZ-complexity at all sequence lengths for a range of quantisation levels.
%
% Default parameters (may be overriden on command line)

defvar('maxn',    100000    ); % length of time series (max 100,000)
defvar('maxq',    5         ); % maximum quantisation
defvar('fs',      200       ); % sampling frequency (Hz)
defvar('oudec',   1         ); % OU process decay parameter (> 0); smaller oudec gives "smoother" process
defvar('algo',   'LZ'       ); % Lempel-Ziv algorithm: 'LZ' or 'LZ76'

switch upper(algo)
	case 'LZ',   lz76 = false; algostr = 'LZc';
	case 'LZ76', lz76 = true;  algostr = 'LZ76c';
	otherwise, error('Lempel-Ziv algorithm must be ''LZ'' or ''LZ76''');
end
% Generate an (approximate) Ornstein-Uhlenbeck time series

fprintf('\ngenerating OU time series... ');
dt     = 1/fs;                         % integration time step size
trunc  = maxn;                         % initial samples to truncate (for transients)
totn   = trunc+maxn;                   % total simulation steps
a      = 1-oudec*dt;                   % autoregression coefficient
x      = sqrt(dt)*randn(totn,1);       % initialise to Gaussian white noise (variance adjusted for step size)
for i = 2:totn;
	x(i) = x(i) + a*x(i-1);            % generate approximate OU time series by autoregression
end
x = x(trunc+1:totn);                   % truncate initial transients
fprintf('done\n\n');

% Calculate complexities for different quantisation levels, and load random string complexities

c      = zeros(maxn,maxq);                 % complexities of x
crnd   = zeros(maxn,maxq);                 % random string complexities
qtiles = cell(maxq,1);                     % quantiles
for q = 1:maxq                             % for each quantisation
	fprintf('processing qauntisation %d of %d... ',q,maxq);
	d = q+1;                               % alphabet size = number of quantiles + 1
	[s,qtiles{q}] = LZc_quantise(x,q);     % quantise noise sequence by q quantiles; store quantiles
	if lz76
		c(:,q) = LZ76c_x(s,d);             % calculate "running" LZ76 complexity (i.e., for all sequence lengths to maximum)
		crnd(:,q) = LZ76c_crand(1:maxn,d); % load random string mean complexities from file
	else
		c(:,q) = LZc_x(s,d);               % calculate "running" LZ complexity (i.e., for all sequence lengths to maximum)
		crnd(:,q) = LZc_crand(1:maxn,d);   % load random string mean complexities from file
	end
	fprintf('done\n');
end
cnorm = c./crnd;                       % complexities normalised by mean complexity of random strings of same length and alphabet size

n = (1:maxn)'; % sequence lengths
t = dt*(n-1);  % corresponding time stamps

% Display time series with quantiles

figure(1); clf

xmax = 1.05*max(abs(x));
for q = 1:maxq
	subplot(maxq,1,q);
	plot(t,x);
	for k = 1:q
		yline(qtiles{q}(k),'color','r');
	end
	xlim([0,dt*maxn]);
	ylim([-xmax xmax]);
	xlabel('time (secs)');
	ylabel(sprintf('q = %d',q));
end
% sgtitle('Time series with quantisations'); % only version >= 2018b

% Estimate power spectral density (PSD) of time series

[S,f] = pwelch(x,[],[],[],fs);         % estimated PSD (Welch method)
w = 2*pi*f/fs;                         % normalised frequency in [0,pi]
ST = dt*abs(1./(1-a*exp(-1i*w))).^2;   % theoretical PSD

% Display PSD and normalised complexities

figure(2); clf

subplot(2,1,1);
semilogx(f,log([(fs/2)*S,ST]));
xlim([f(2) fs/2]); % to Nyqvist frequency
title(sprintf('Power spectral density (f_s = %gHz)',fs));
legend('estimated','theoretical');
xlabel('frequency (Hz; log-scale)');
ylabel('log-power (dB)');
set(gca,'XTickLabel',num2str(get(gca,'XTick')')); % ridiculous faff to force sensible tick labels

subplot(2,1,2);
semilogx(n,cnorm);
ylim([0 1.2]);
yline(1,'color','k');
title(sprintf('normalised %s complexity',algostr));
xlabel('sequence length (log-scale)');
ylabel('complexity');
leg = legend(num2str((1:maxq)','%2d'),'location','southwest');
leg.Title.Visible = 'on';
title(leg,'quantiles');
grid on
