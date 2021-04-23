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

prompt='Please input the simulation duration (ms):';
sim_dur = input(prompt); %duration of the simulation

for ii = (1:(Nn))
    % to obtain the LFP here we extract, from the burning matrix, the 
    % membrane potential updates of all the neurons of the node N, and 
    % reorganize the data as follows:
    % [b_time, b_node, b_neuron, initial internal state, reached internal state]
    
    LFP(ii).contributions  = b_mat(b_mat(:,4) == (ii-1), [1,4,5,7,8]);

    LFP(ii).sorted_contributions = sortrows (LFP(ii).contributions,1); % first, sort for times (sometimes spikes can appear disordered in the CSV)
    LFP(ii).sorted_contributions = sortrows (LFP(ii).sorted_contributions,3); % then sort for neuron number
    
    for jj = (1:(1+max(LFP(ii).sorted_contributions(:,3)))) % for each neuron of the node
        clear temp temp2 temp3
        LFP(ii).time_series_collect (jj,1) = {LFP(ii).sorted_contributions(LFP(ii).sorted_contributions(:,3) == (jj-1), [3,1,4,5])'}; % store contributions in cell-structures: neuron number, time, from state, to state
        temp= cell2mat(LFP(ii).time_series_collect (jj,1)); % move the neuron-specific contribution in a temporary array
        if ~isempty(temp); % this if is to process only the output of neurons that produced spikes

            for kk= 1:size(temp,2)
                temp2 (1:2,(2*kk-1)) = [temp(2,kk) ; temp(3,kk)]; % low points of LFP
                temp2 (1:2,(2*kk)) = [temp(2,kk) ; temp(4,kk)]; % high points of LFP
            end
        
            for kk= 2:size(temp2,2) % level pre-resting potentials to S=6.0 (although higher peaks can appear due to the previous sample)         
                 if and (temp2 (2,(kk))==0 , temp2 (2,(kk-1)) >= 1.04)
                    temp2 (2,(kk-2:kk-1))=6;
                 end
            end
            LFP(ii).time_series_collect (jj,2) = {temp2}; % store non-uniformly sampled time-series in cells: 
            temp3 = resample(temp2(2,:),temp2(1,:),1000); % resample with a very high frequency
            temp3= downsample(temp3,1000); % store final uniformly sampled signal in cells
            LFP(ii).time_series_collect (jj,3) = {temp3(1,1:sim_dur)}; % equalize the lengths in case some samples are longer than others
        
        else LFP(ii).time_series_collect (jj,3) = {zeros(1,sim_dur)}; 
        
        end
    end
    
    LFP(ii).signal=sum(cell2mat(LFP(ii).time_series_collect (:,3)));
     

    % here we generate the related FFTs
    LFP(ii).FFTtot = abs(fft(LFP(ii).signal)/sim_dur);
    LFP(ii).FFT = 2*LFP(ii).FFTtot(1:sim_dur/2+1);

    f = 1000 *(0:(sim_dur/2))/sim_dur; % sampling freq. = 1000
    
end



%% PLOT broadband time series of simulated activity

% plot the N simulated signals
figure ()
for ii = (1:Nn)
    ax(ii) = subplot(Nn,1,ii);
    plot (smooth(LFP(ii).signal','lowess')); xlim([0 sim_dur]); ylabel(['N_' num2str(ii-1)]); % Smoothed
    
    if ii==1
        title('Simulated postsynaptic signal (LFP)');
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
    plot (f, smooth(LFP(ii).FFT,'lowess')'); ylabel(['N_' num2str(ii-1)]); % Smoothed
    
    if ii==1
        title('|A1(f)| : Single-Sided Amplitude Spectrum of LFP');
    end
    if ii==Nn
        xlabel('f (Hz)'); % for x-axis label
    else
        set(gca,'XTickLabel',[]);
    end
    xlim([1 100]) % Spectrum frequency interval (if inf=1 then DC is not plotted)
end

xlabel('f (Hz)'); % for x-axis label
