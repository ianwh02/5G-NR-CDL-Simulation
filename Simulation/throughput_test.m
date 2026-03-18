simParameters = struct();       % Clear simParameters variable to contain all key simulation parameters
simParameters.NFrames = 2;      % Number of 10 ms frames
simParameters.SNRIn = [-5 0 5]; % SNR range (dB)
%simParameters.SNRIn = -5:1:20; % SNR range (dB)

%simParameters.UseGPU = "on";
simParameters.PerfectChannelEstimator = true;
simParameters.DisplaySimulationInformation = true;
simParameters.DisplayDiagnostics = false;

%Set waveform type and PDSCH numerology (SCS and CP type)
simParameters.Carrier = nrCarrierConfig;         % Carrier resource grid configuration
simParameters.Carrier.NSizeGrid = 51;            % Bandwidth in number of resource blocks (51 RBs at 30 kHz SCS for 20 MHz BW)
simParameters.Carrier.SubcarrierSpacing = 30;    % 15, 30, 60, 120 (kHz)
simParameters.Carrier.CyclicPrefix = 'Normal';   % 'Normal' or 'Extended' (Extended CP is relevant for 60 kHz SCS only)
simParameters.Carrier.NCellID = 1;               % Cell identity

% PDSCH/DL-SCH parameters
simParameters.PDSCH = nrPDSCHConfig;      % This PDSCH definition is the basis for all PDSCH transmissions in the BLER simulation
simParameters.PDSCHExtension = struct();  % This structure is to hold additional simulation parameters for the DL-SCH and PDSCH

% Define PDSCH time-frequency resource allocation per slot to be full grid (single full grid BWP)
simParameters.PDSCH.PRBSet = 0:simParameters.Carrier.NSizeGrid-1;                 % PDSCH PRB allocation
simParameters.PDSCH.SymbolAllocation = [2, 12];  % Starting symbol and number of symbols of each PDSCH allocation
simParameters.PDSCH.MappingType = 'A';     % PDSCH mapping type ('A'(slot-wise),'B'(non slot-wise))

% Scrambling identifiers
simParameters.PDSCH.NID = simParameters.Carrier.NCellID;
simParameters.PDSCH.RNTI = 1;

% PDSCH resource block mapping (TS 38.211 Section 7.3.1.6)
simParameters.PDSCH.VRBToPRBInterleaving = 0; % Disable interleaved resource mapping
simParameters.PDSCH.VRBBundleSize = 4;

% Define the number of transmission layers to be used
simParameters.PDSCH.NumLayers = 2;            % Number of PDSCH transmission layers

% Define codeword modulation and target coding rate
% The number of codewords is directly dependent on the number of layers so ensure that
% layers are set first before getting the codeword number
if simParameters.PDSCH.NumCodewords > 1                             % Multicodeword transmission (when number of layers being > 4)
    simParameters.PDSCH.Modulation = {'64QAM','64QAM'};             % 'QPSK', '16QAM', '64QAM', '256QAM'
    simParameters.PDSCHExtension.TargetCodeRate = [490 490]/1024;   % Code rate used to calculate transport block sizes
else
    simParameters.PDSCH.Modulation = '64QAM';                       % 'QPSK', '16QAM', '64QAM', '256QAM'
    simParameters.PDSCHExtension.TargetCodeRate = 490/1024;         % Code rate used to calculate transport block sizes
end

% DM-RS and antenna port configuration (TS 38.211 Section 7.4.1.1)
simParameters.PDSCH.DMRS.DMRSPortSet = 0:simParameters.PDSCH.NumLayers-1; % DM-RS ports to use for the layers
simParameters.PDSCH.DMRS.DMRSTypeAPosition = 2;      % Mapping type A only. First DM-RS symbol position (2,3)
if simParameters.PDSCH.NumCodewords > 1
    simParameters.PDSCH.DMRS.DMRSLength = 2;             % Number of front-loaded DM-RS symbols (1(single symbol),2(double symbol))
else
    simParameters.PDSCH.DMRS.DMRSLength = 1;
end
simParameters.PDSCH.DMRS.DMRSAdditionalPosition = 1; % Additional DM-RS symbol positions (max range 0...3)
simParameters.PDSCH.DMRS.DMRSConfigurationType = 1;  % DM-RS configuration type (1,2)
simParameters.PDSCH.DMRS.NumCDMGroupsWithoutData = 1;% Number of CDM groups without data
simParameters.PDSCH.DMRS.NIDNSCID = 1;               % Scrambling identity (0...65535)
simParameters.PDSCH.DMRS.NSCID = 0;                  % Scrambling initialization (0,1)

% PT-RS configuration (TS 38.211 Section 7.4.1.2)
simParameters.PDSCH.EnablePTRS = 0;                  % Enable or disable PT-RS (1 or 0)
simParameters.PDSCH.PTRS.TimeDensity = 1;            % PT-RS time density (L_PT-RS) (1, 2, 4)
simParameters.PDSCH.PTRS.FrequencyDensity = 2;       % PT-RS frequency density (K_PT-RS) (2 or 4)
simParameters.PDSCH.PTRS.REOffset = '00';            % PT-RS resource element offset ('00', '01', '10', '11')
simParameters.PDSCH.PTRS.PTRSPortSet = [];           % PT-RS antenna port, subset of DM-RS port set. Empty corresponds to lower DM-RS port number

% Reserved PRB patterns, if required (for CORESETs, forward compatibility etc)
simParameters.PDSCH.ReservedPRB{1}.SymbolSet = [];   % Reserved PDSCH symbols
simParameters.PDSCH.ReservedPRB{1}.PRBSet = [];      % Reserved PDSCH PRBs
simParameters.PDSCH.ReservedPRB{1}.Period = [];      % Periodicity of reserved resources

% Additional simulation and DL-SCH related parameters
%
% PDSCH PRB bundling (TS 38.214 Section 5.1.2.3)
simParameters.PDSCHExtension.PRGBundleSize = 2;     % 2, 4, or [] to signify "wideband"
%
% HARQ process and rate matching/TBS parameters
simParameters.PDSCHExtension.XOverhead = 6*simParameters.PDSCH.EnablePTRS; % Set PDSCH rate matching overhead for TBS (Xoh) to 6 when PT-RS is enabled, otherwise 0
simParameters.PDSCHExtension.NHARQProcesses = 8;    % Number of parallel HARQ processes to use
simParameters.PDSCHExtension.EnableHARQ = false;      % Enable retransmissions for each process, using RV sequence [0,2,3,1]
simParameters.PDSCHExtension.EnableCBGTransmission = true; % Enable CBG-based transmission, otherwise TB-based transmission
simParameters.PDSCHExtension.MaxNumCBG = 4;          % Maximum number of CBGs per transport block for each HARQ process in CBG-based transmission

% LDPC decoder parameters
% Available algorithms: 'Belief propagation', 'Layered belief propagation', 'Normalized min-sum', 'Offset min-sum'
simParameters.PDSCHExtension.LDPCDecodingAlgorithm = 'Normalized min-sum';
simParameters.PDSCHExtension.MaximumLDPCIterationCount = 6;

% Define the overall transmission antenna geometry at end-points
% If using a CDL propagation channel then the integer number of antenna elements is
% turned into an antenna panel configured when the channel model object is created
simParameters.NTxAnts = 4;                        % Number of PDSCH transmission antennas (1,2,4,8,16,32,64,128,256,512,1024) >= NumLayers
simParameters.NRxAnts = 4;

% Define data type ('single' or 'double') for resource grids and waveforms
simParameters.DataType = 'single';

% Define the general CDL/TDL propagation channel parameters
simParameters.DelayProfile = 'CDL-C';      % Use CDL-C model (Urban macrocell model)
%simParameters.DelaySpread = 300e-9;
simParameters.MaximumDopplerShift = 10;

% Cross-check the PDSCH layering against the channel geometry
validateNumLayers(simParameters);

waveformInfo = nrOFDMInfo(simParameters.Carrier); % Get information about the baseband waveform after OFDM modulation step

% Constructed the CDL or TDL channel model object
if contains(simParameters.DelayProfile,'CDL','IgnoreCase',true)

    channel = nrCDLChannel; % CDL channel object
    channel.TransmitAntennaArray = struct('Size',[8 2 2 8 1], ... % [8 2 2 8 1] for 4Tx, [8 4 2 8 1] for 8Tx
        'ElementSpacing',[0.5 0.5 4 1], ...
        'PolarizationAngles', [-45 45], ...
        'Orientation', [180; 0; 0], ...
        'Element', '38.901', ...
        'PolarizationModel', 'Model-2'); 
    channel.ReceiveAntennaArray = struct('Size',[2 1 2 1 1], ... % [2 1 2 1 1] for 4Rx, [2 2 2 1 1] for 8Rx
        'ElementSpacing',[0.5 0.5 1 1], ...
        'PolarizationAngles', [-45 45], ...
        'Orientation', [0; 10; 0], ...
        'Element', 'isotropic', ...
        'PolarizationModel', 'Model-2');
    simParameters.NTxAnts = prod(channel.TransmitAntennaArray.Size);
    simParameters.NRxAnts = prod(channel.ReceiveAntennaArray.Size);
else
    channel = nrTDLChannel; % TDL channel object

    % Configure the channel to automatically select a sample rate for
    % generating channel coefficients
    channel.PathGainSampleRate = 'auto';

    % Set the channel geometry
    channel.NumTransmitAntennas = simParameters.NTxAnts;
    channel.NumReceiveAntennas = simParameters.NRxAnts;
end

% Assign simulation channel parameters and waveform sample rate to the
% object, and specify OFDM channel response as the channel response output
% so that perfect channel estimation is calculated while filtering the
% signal
channel.DelayProfile = simParameters.DelayProfile;
%channel.DelaySpread = simParameters.DelaySpread;
channel.MaximumDopplerShift = simParameters.MaximumDopplerShift;
channel.SampleRate = waveformInfo.SampleRate;
channel.ChannelResponseOutput = 'ofdm-response';

chInfo = info(channel);
maxChDelay = chInfo.MaximumChannelDelay;

% if simParameters.UseGPU == "on" || (simParameters.UseGPU == "auto" && canUseGPU)
%     device = gpuDevice().Name;
%     fprintf('\nUsing GPU device %s for computation\n',device);
%     simParameters.Prototype = zeros(0,0,simParameters.DataType,"gpuArray");
%     if class(channel) == "nrTDLChannel"
%         error("The nrTDLChannel object does not support GPU arrays. Use an nrCDLChannel object instead.")
%     end
% else
%     simParameters.Prototype =  zeros(0,0,simParameters.DataType);
% end

% Array to store the maximum throughput for all SNR points
maxThroughput = zeros(length(simParameters.SNRIn),1);
% Array to store the simulation throughput for all SNR points
simThroughput = zeros(length(simParameters.SNRIn),1);

% Set up redundancy version (RV) sequence for all HARQ processes
if simParameters.PDSCHExtension.EnableHARQ
    % In the final report of RAN WG1 meeting #91 (R1-1719301), it was
    % observed in R1-1717405 that if performance is the priority, [0 2 3 1]
    % should be used. If self-decodability is the priority, it should be
    % taken into account that the upper limit of the code rate at which
    % each RV is self-decodable is in the following order: 0>3>2>1
    rvSeq = [0 2 3 1];
else
    % HARQ disabled - single transmission with RV=0, no retransmissions
    rvSeq = 0;
end

% Create DL-SCH encoder system object to perform transport channel encoding
encodeDLSCH = nrDLSCH;
encodeDLSCH.MultipleHARQProcesses = true;
encodeDLSCH.TargetCodeRate = simParameters.PDSCHExtension.TargetCodeRate;

% Create DL-SCH decoder system object to perform transport channel decoding
% Use layered belief propagation for LDPC decoding, with half the number of
% iterations as compared to the default for belief propagation decoding
decodeDLSCH = nrDLSCHDecoder;
decodeDLSCH.MultipleHARQProcesses = true;
decodeDLSCH.TargetCodeRate = simParameters.PDSCHExtension.TargetCodeRate;
decodeDLSCH.LDPCDecodingAlgorithm = simParameters.PDSCHExtension.LDPCDecodingAlgorithm;
decodeDLSCH.MaximumLDPCIterationCount = simParameters.PDSCHExtension.MaximumLDPCIterationCount;

for snrIdx = 1:numel(simParameters.SNRIn)      % comment out for parallel computing
% parfor snrIdx = 1:numel(simParameters.SNRIn) % uncomment for parallel computing
% To reduce the total simulation time, you can execute this loop in
% parallel by using the Parallel Computing Toolbox. Comment out the 'for'
% statement and uncomment the 'parfor' statement. If the Parallel Computing
% Toolbox is not installed, 'parfor' defaults to normal 'for' statement.
% Because parfor-loop iterations are executed in parallel in a
% nondeterministic order, the simulation information displayed for each SNR
% point can be intertwined. To switch off simulation information display,
% set the 'displaySimulationInformation' variable above to false

    % Reset the random number generator so that each SNR point will
    % experience the same noise realization
    rng('default');

    % Take full copies of the simulation-level parameter structures so that they are not
    % PCT broadcast variables when using parfor
    simLocal = simParameters;
    waveinfoLocal = waveformInfo;

    % Take copies of channel-level parameters to simplify subsequent parameter referencing
    carrier = simLocal.Carrier;
    pdsch = simLocal.PDSCH;
    pdschextra = simLocal.PDSCHExtension;
    decodeDLSCHLocal = decodeDLSCH;  % Copy of the decoder handle to help PCT classification of variable
    decodeDLSCHLocal.reset();        % Reset decoder at the start of each SNR point
    pathFilters = [];

    % Prepare simulation for new SNR point
    SNRdB = simLocal.SNRIn(snrIdx);
    fprintf('\nSimulating transmission scheme 1 (%dx%d) and SCS=%dkHz with %s channel at %gdB SNR for %d 10ms frame(s)\n', ...
        simLocal.NTxAnts,simLocal.NRxAnts,carrier.SubcarrierSpacing, ...
        simLocal.DelayProfile,SNRdB,simLocal.NFrames);

    % Specify the fixed order in which we cycle through the HARQ process IDs
    harqSequence = 0:pdschextra.NHARQProcesses-1;

    % Initialize the state of all HARQ processes
    harqEntity = HARQEntity(harqSequence,rvSeq,pdsch.NumCodewords);

    % Reset the channel so that each SNR point will experience the same
    % channel realization
    reset(channel);

    % Total number of slots in the simulation period
    NSlots = simLocal.NFrames * carrier.SlotsPerFrame;

    % Obtain a precoding matrix (wtx) to be used in the transmission of the
    % first transport block
    estChannelGridAnts = getInitialChannelEstimate(carrier,channel,simLocal.DataType,maxChDelay);
    newWtx = hSVDPrecoders(carrier,pdsch,estChannelGridAnts,pdschextra.PRGBundleSize);

    % Timing offset, updated in every slot for perfect synchronization and
    % when the correlation is strong for practical synchronization
    offset = 0;

    % Noise power, normalized by the IFFT size used in OFDM modulation, as
    % the OFDM modulator applies this normalization to the transmitted
    % waveform. Also normalize by the number of receive antennas, as the
    % channel model applies this normalization to the received waveform by
    % default. Calculate the noise power per RE to act as the noise
    % estimate if perfect channel estimation is enabled
    SNR = 10^(SNRdB/10);
    N0 = 1/sqrt(simLocal.NRxAnts*double(waveinfoLocal.Nfft)*SNR);
    nPowerPerRE = N0^2*double(waveinfoLocal.Nfft);

    % Loop over the entire waveform length
    for nslot = 0:NSlots-1

        % Update the carrier slot numbers for new slot
        carrier.NSlot = nslot;

        % Calculate the transport block sizes for the transmission in the slot
        [pdschIndices,pdschIndicesInfo] = nrPDSCHIndices(carrier,pdsch);
        trBlkSizes = nrTBS(pdsch.Modulation,pdsch.NumLayers,numel(pdsch.PRBSet),pdschIndicesInfo.NREPerPRB,pdschextra.TargetCodeRate,pdschextra.XOverhead);

        % HARQ processing
        for cwIdx = 1:pdsch.NumCodewords
            % If new data for current process and codeword then create a new DL-SCH transport block
            if harqEntity.NewData(cwIdx)
                trBlk = randi([0 1],trBlkSizes(cwIdx),1);
                setTransportBlock(encodeDLSCH,trBlk,cwIdx-1,harqEntity.HARQProcessID);
                % If new data because of previous RV sequence time out then flush decoder soft buffer explicitly
                if harqEntity.SequenceTimeout(cwIdx)
                    resetSoftBuffer(decodeDLSCHLocal,cwIdx-1,harqEntity.HARQProcessID);
                end
            end
        end

        % Encode the DL-SCH transport blocks
        codedTrBlocks = encodeDLSCH(pdsch.Modulation,pdsch.NumLayers, ...
            pdschIndicesInfo.G,harqEntity.RedundancyVersion,harqEntity.HARQProcessID);

        % Get precoding matrix (wtx) calculated in previous slot
        wtx = newWtx;

        % Create resource grid for a slot
        pdschGrid = nrResourceGrid(carrier,simLocal.NTxAnts,OutputDataType=simLocal.DataType);

        % PDSCH modulation and precoding
        pdschSymbols = nrPDSCH(carrier,pdsch,codedTrBlocks);
        [pdschAntSymbols,pdschAntIndices] = nrPDSCHPrecode(carrier,pdschSymbols,pdschIndices,wtx);

        % PDSCH mapping in grid associated with PDSCH transmission period
        pdschGrid(pdschAntIndices) = pdschAntSymbols;

        % PDSCH DM-RS precoding and mapping
        dmrsSymbols = nrPDSCHDMRS(carrier,pdsch);
        dmrsIndices = nrPDSCHDMRSIndices(carrier,pdsch);
        [dmrsAntSymbols,dmrsAntIndices] = nrPDSCHPrecode(carrier,dmrsSymbols,dmrsIndices,wtx);
        pdschGrid(dmrsAntIndices) = dmrsAntSymbols;

        % PDSCH PT-RS precoding and mapping
        ptrsSymbols = nrPDSCHPTRS(carrier,pdsch);
        ptrsIndices = nrPDSCHPTRSIndices(carrier,pdsch);
        [ptrsAntSymbols,ptrsAntIndices] = nrPDSCHPrecode(carrier,ptrsSymbols,ptrsIndices,wtx);
        pdschGrid(ptrsAntIndices) = ptrsAntSymbols;

        % OFDM modulation
        txWaveform = nrOFDMModulate(carrier,pdschGrid);

        % Pass data through channel model. Append zeros at the end of the
        % transmitted waveform to flush channel content. These zeros take
        % into account any delay introduced in the channel. This is a mix
        % of multipath delay and implementation delay. This value may
        % change depending on the sampling rate, delay profile, and delay
        % spread. The channel model also returns the OFDM channel response
        % and timing offset for the specified carrier
        txWaveform = [txWaveform; zeros(maxChDelay,size(txWaveform,2))]; %#ok<AGROW>
        [rxWaveform,ofdmResponse,timingOffset] = channel(txWaveform,carrier);

        % Add AWGN to the received time domain waveform
        noise = N0*randn(size(rxWaveform),"like",rxWaveform);
        rxWaveform = rxWaveform + noise;

        if (simLocal.PerfectChannelEstimator)
            % For perfect synchronization, use the timing offset obtained
            % from the channel
            offset = timingOffset;
        else
            % Practical synchronization. Correlate the received waveform
            % with the PDSCH DM-RS to give timing offset estimate 't' and
            % correlation magnitude 'mag'. The function
            % hSkipWeakTimingOffset is used to update the receiver timing
            % offset. If the correlation peak in 'mag' is weak, the current
            % timing estimate 't' is ignored and the previous estimate
            % 'offset' is used
            [t,mag] = nrTimingEstimate(carrier,rxWaveform,dmrsIndices,dmrsSymbols);
            offset = hSkipWeakTimingOffset(offset,t,mag);
            % Display a warning if the estimated timing offset exceeds the
            % maximum channel delay
            if offset > maxChDelay
                warning(['Estimated timing offset (%d) is greater than the maximum channel delay (%d).' ...
                    ' This will result in a decoding failure. This may be caused by low SNR,' ...
                    ' or not enough DM-RS symbols to synchronize successfully.'],offset,maxChDelay);
            end
        end
        rxWaveform = rxWaveform(1+offset:end,:);

        % Perform OFDM demodulation on the received data to recreate the
        % resource grid, including padding in the event that practical
        % synchronization results in an incomplete slot being demodulated
        rxGrid = nrOFDMDemodulate(carrier,rxWaveform);
        [K,L,R] = size(rxGrid);
        if (L < carrier.SymbolsPerSlot)
            rxGrid = cat(2,rxGrid,zeros(K,carrier.SymbolsPerSlot-L,R));
        end

        if (simLocal.PerfectChannelEstimator)
            % For perfect channel estimate, use the OFDM channel response
            % obtained from the channel
            estChannelGridAnts = ofdmResponse;

            % For perfect noise estimate, use the noise power per RE
            noiseEst = nPowerPerRE;

            % Get PDSCH resource elements from the received grid and
            % channel estimate
            [pdschRx,pdschHest,~,pdschHestIndices] = nrExtractResources(pdschIndices,rxGrid,estChannelGridAnts);

            % Apply precoding to channel estimate
            pdschHest = nrPDSCHPrecode(carrier,pdschHest,pdschHestIndices,permute(wtx,[2 1 3]));
        else
            % Practical channel estimation between the received grid and
            % each transmission layer, using the PDSCH DM-RS for each
            % layer. This channel estimate includes the effect of
            % transmitter precoding
            [estChannelGridPorts,noiseEst] = hSubbandChannelEstimate(carrier,rxGrid,dmrsIndices,dmrsSymbols,pdschextra.PRGBundleSize,'CDMLengths',pdsch.DMRS.CDMLengths);

            % Average noise estimate across PRGs and layers
            noiseEst = mean(noiseEst,'all');

            % Get PDSCH resource elements from the received grid and
            % channel estimate
            [pdschRx,pdschHest] = nrExtractResources(pdschIndices,rxGrid,estChannelGridPorts);

            % Remove precoding from estChannelGridPorts to get channel
            % estimate w.r.t. antennas
            estChannelGridAnts = precodeChannelEstimate(carrier,estChannelGridPorts,conj(wtx));
        end

        % Equalization
        [pdschEq,csi] = nrEqualizeMMSE(pdschRx,pdschHest,noiseEst);

        % Common phase error (CPE) compensation
        if ~isempty(ptrsIndices)
            % Initialize temporary grid to store equalized symbols
            tempGrid = nrResourceGrid(carrier,pdsch.NumLayers);

            % Extract PT-RS symbols from received grid and estimated
            % channel grid
            [ptrsRx,ptrsHest,~,~,ptrsHestIndices,ptrsLayerIndices] = nrExtractResources(ptrsIndices,rxGrid,estChannelGridAnts,tempGrid);
            ptrsHest = nrPDSCHPrecode(carrier,ptrsHest,ptrsHestIndices,permute(wtx,[2 1 3]));

            % Equalize PT-RS symbols and map them to tempGrid
            ptrsEq = nrEqualizeMMSE(ptrsRx,ptrsHest,noiseEst);
            tempGrid(ptrsLayerIndices) = ptrsEq;

            % Estimate the residual channel at the PT-RS locations in
            % tempGrid
            cpe = nrChannelEstimate(tempGrid,ptrsIndices,ptrsSymbols);

            % Sum estimates across subcarriers, receive antennas, and
            % layers. Then, get the CPE by taking the angle of the
            % resultant sum
            cpe = angle(sum(cpe,[1 3 4]));

            % Map the equalized PDSCH symbols to tempGrid
            tempGrid(pdschIndices) = pdschEq;

            % Correct CPE in each OFDM symbol within the range of reference
            % PT-RS OFDM symbols
            symLoc = pdschIndicesInfo.PTRSSymbolSet(1)+1:pdschIndicesInfo.PTRSSymbolSet(end)+1;
            tempGrid(:,symLoc,:) = tempGrid(:,symLoc,:).*exp(-1i*cpe(symLoc));

            % Extract PDSCH symbols
            pdschEq = tempGrid(pdschIndices);
        end

        % Decode PDSCH physical channel
        [dlschLLRs,rxSymbols] = nrPDSCHDecode(carrier,pdsch,pdschEq,noiseEst);

        % Display EVM per layer, per slot and per RB
        if (simLocal.DisplayDiagnostics)
            plotLayerEVM(NSlots,nslot,pdsch,size(pdschGrid),pdschIndices,pdschSymbols,pdschEq);
        end

        % Scale LLRs by CSI
        csi = nrLayerDemap(csi); % CSI layer demapping
        for cwIdx = 1:pdsch.NumCodewords
            Qm = length(dlschLLRs{cwIdx})/length(rxSymbols{cwIdx}); % bits per symbol
            csi{cwIdx} = repmat(csi{cwIdx}.',Qm,1);                 % expand by each bit per symbol
            dlschLLRs{cwIdx} = dlschLLRs{cwIdx} .* csi{cwIdx}(:);   % scale by CSI
        end

        % Decode the DL-SCH transport channel
        decodeDLSCHLocal.TransportBlockLength = trBlkSizes;
        [decbits,blkerr] = decodeDLSCHLocal(dlschLLRs,pdsch.Modulation,pdsch.NumLayers,harqEntity.RedundancyVersion,harqEntity.HARQProcessID);

        % Store values to calculate throughput
        simThroughput(snrIdx) = simThroughput(snrIdx) + sum(~blkerr .* trBlkSizes);
        maxThroughput(snrIdx) = maxThroughput(snrIdx) + sum(trBlkSizes);

        % Update current process with CRC error and advance to next process
        procstatus = updateAndAdvance(harqEntity,blkerr,trBlkSizes,pdschIndicesInfo.G);
        if (simLocal.DisplaySimulationInformation)
            fprintf('\n(%3.2f%%) NSlot=%d, %s',100*(nslot+1)/NSlots,nslot,procstatus);
        end

        % Get precoding matrix for next slot
        newWtx = hSVDPrecoders(carrier,pdsch,estChannelGridAnts,pdschextra.PRGBundleSize);

     end

    % Display the results dynamically in the command window
    if (simLocal.DisplaySimulationInformation)
        fprintf('\n');
    end
    fprintf('\nThroughput(Mbps) for %d frame(s) = %.4f\n',simLocal.NFrames,1e-6*simThroughput(snrIdx)/(simLocal.NFrames*10e-3));
    fprintf('Throughput(%%) for %d frame(s) = %.4f\n',simLocal.NFrames,simThroughput(snrIdx)*100/maxThroughput(snrIdx));

end

figure;
plot(simParameters.SNRIn,simThroughput*100./maxThroughput,'o-.')
xlabel('SNR (dB)'); ylabel('Throughput (%)'); grid on;
title(sprintf('%s (%dx%d) / NRB=%d / SCS=%dkHz', ...
              simParameters.DelayProfile,getNumPorts(channel.TransmitAntennaArray.Size),simParameters.NRxAnts, ...
              simParameters.Carrier.NSizeGrid,simParameters.Carrier.SubcarrierSpacing));

% Bundle key parameters and results into a combined structure for recording
simResults.simParameters = simParameters;
simResults.simThroughput = simThroughput;
simResults.maxThroughput = maxThroughput;

relative_throughput = simThroughput*100./maxThroughput;

T = table(simParameters.SNRIn(:), relative_throughput(:), 'VariableNames', {'SNR_dB', 'Relative Throughput'});

writetable(T, 'simulation_results.xlsx');

function validateNumLayers(simParameters)
% Validate the number of layers, relative to the antenna geometry

    numlayers = simParameters.PDSCH.NumLayers;
    ntxants = simParameters.NTxAnts;
    nrxants = simParameters.NRxAnts;
    antennaDescription = sprintf('min(NTxAnts,NRxAnts) = min(%d,%d) = %d',ntxants,nrxants,min(ntxants,nrxants));
    if numlayers > min(ntxants,nrxants)
        error('The number of layers (%d) must satisfy NumLayers <= %s', ...
            numlayers,antennaDescription);
    end

    % Display a warning if the maximum possible rank of the channel equals
    % the number of layers
    if (numlayers > 2) && (numlayers == min(ntxants,nrxants))
        warning(['The maximum possible rank of the channel, given by %s, is equal to NumLayers (%d).' ...
            ' This may result in a decoding failure under some channel conditions.' ...
            ' Try decreasing the number of layers or increasing the channel rank' ...
            ' (use more transmit or receive antennas).'],antennaDescription,numlayers); %#ok<SPWRN>
    end

end

function estChannelGrid = getInitialChannelEstimate(carrier,propchannel,dataType,maxChDelay)
% Obtain channel estimate before first transmission. This can be used to
% obtain a precoding matrix for the first slot.

    ofdmInfo = nrOFDMInfo(carrier);

    % Clone of the channel
    chClone = propchannel.clone();
    chClone.release();

    % No filtering needed to get perfect channel estimate
    chClone.ChannelFiltering = false;
    chClone.OutputDataType = dataType;
    chClone.NumTimeSamples = (ofdmInfo.SampleRate/1000/carrier.SlotsPerSubframe)+maxChDelay;

    % Get the perfect channel estimate
    estChannelGrid = chClone(carrier);

end

function estChannelGrid = precodeChannelEstimate(carrier,estChannelGrid,W)
% Apply precoding matrix W to the last dimension of the channel estimate

    [K,L,R,P] = size(estChannelGrid);
    estChannelGrid = reshape(estChannelGrid,[K*L R P]);
    estChannelGrid = nrPDSCHPrecode(carrier,estChannelGrid,reshape(1:numel(estChannelGrid),[K*L R P]),W);
    estChannelGrid = reshape(estChannelGrid,K,L,R,[]);

end

function plotLayerEVM(NSlots,nslot,pdsch,siz,pdschIndices,pdschSymbols,pdschEq)
% Plot EVM information

    persistent slotEVM;
    persistent rbEVM
    persistent evmPerSlot;

    if (nslot==0)
        slotEVM = comm.EVM;
        rbEVM = comm.EVM;
        evmPerSlot = NaN(NSlots,pdsch.NumLayers);
        figure;
    end
    evmPerSlot(nslot+1,:) = slotEVM(pdschSymbols,pdschEq);
    subplot(2,1,1);
    plot(0:(NSlots-1),evmPerSlot,'o-');
    xlabel('Slot number');
    ylabel('EVM (%)');
    legend("layer " + (1:pdsch.NumLayers),'Location','EastOutside');
    title('EVM per layer per slot');

    subplot(2,1,2);
    [k,~,p] = ind2sub(siz,pdschIndices);
    rbsubs = floor((k-1) / 12);
    NRB = siz(1) / 12;
    evmPerRB = NaN(NRB,pdsch.NumLayers);
    for nu = 1:pdsch.NumLayers
        for rb = unique(rbsubs).'
            this = (rbsubs==rb & p==nu);
            evmPerRB(rb+1,nu) = rbEVM(pdschSymbols(this),pdschEq(this));
        end
    end
    plot(0:(NRB-1),evmPerRB,'x-');
    xlabel('Resource block');
    ylabel('EVM (%)');
    legend("layer " + (1:pdsch.NumLayers),'Location','EastOutside');
    title(['EVM per layer per resource block, slot #' num2str(nslot)]);

    drawnow;

end

function nPorts = getNumPorts(arraySize)
    M = arraySize(1);
    N = arraySize(2);
    P = arraySize(3);
    Ms = arraySize(4);
    Ns = arraySize(5);
    nPorts = (M / Ms) * (N / Ns) * P;
end