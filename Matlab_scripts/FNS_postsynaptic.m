%% VISUALIZATION OF THE POSTSYNAPTIC ACTIVITY OF THE MODEL 
% In order to obtain the time series of the postsynaptic 
% potential of single simulation, please rename and put the file 
% burning_matlab.csv (generated from FNS) on the current folder 
% and Run this script. 

T = readtable(sprintf('burning_matlab.csv'));
b_mat = table2array(T);
clearvars T;

prompt='Please input the total number of nodes of the model:'; %start the count from N0
Nn = input(prompt); %number of nodes

prompt='Please input the duration to be visualized (ms):';
sim_dur = input(prompt); %duration of the simulation

edges=[0:1:sim_dur]; %for a resolution of 1 ms in LFP signal generation

for ii = (1:(Nn))
    % to obtain the LFP here we extract, from the burning matrix, the 
    % membrane potential updates of all the neurons of the node N, and 
    % reorganize the data as follows:
    % [b_time, b_node, b_neuron, reached internal state]
    LFP(ii).contributions  = b_mat(b_mat(:,4) == (ii-1), [1,4,5,8]);

    % Collection in bins of 1 ms
    [LFP(ii).signal,edges] = histcounts(LFP(ii).contributions(:,1),edges);

    % here we generate the related FFTs
    LFP(ii).FFTtot = abs(fft(LFP(ii).signal)/sim_dur);
    LFP(ii).FFT = 2*LFP(ii).FFTtot(1:sim_dur/2+1);
    LFP(ii).FFT (1) = 0; % ignore DC component
    f = 1000 *(0:(sim_dur/2))/sim_dur; % sampling freq. = 1000
end

%% PLOT broadband time series of simulated activity

% plot the N simulated signals
figure ()
for ii = (1:Nn)
    ax(ii) = subplot(Nn,1,ii);
    plot (smooth(LFP(ii).signal','lowess')); xlim([0 sim_dur]); ylabel(['N_' num2str(ii-1)]); % Smoothed
    
    if ii==1
        title('Simulated postsynaptic signal');
    end
    if ii==Nn
        xlabel('time (ms)'); % for x-axis label
    else
        set(gca,'XTickLabel',[]);
    end
end
xlabel('time (ms)'); % for x-axis label


% plot the spectra of the N simulated signals
figure ()
for ii = (1:Nn)
    ax(ii) = subplot(Nn,1,ii);
    plot (smooth(LFP(ii).FFT','lowess')); ylabel(['N_' num2str(ii-1)]); % Smoothed
    
    if ii==1
        title('|A1(f)| : Single-Sided Amplitude Spectrum of LFP');
    end
    if ii==Nn
        xlabel('f (Hz)'); % for x-axis label
    else
        set(gca,'XTickLabel',[]);
    end
end
xlabel('f (Hz)'); % for x-axis label
xlim([0 100]) % Spectrum frequency interval
