function data = calc_freqBins(t, freq_range)

data = [];
for i = 1:height(t)
    %frequency of calls 
    calls = t.calls{i};
    %logical statement of which calls are in frequency range range. Conver
    %to Hz
    calls_inFrequency = isInRange(calls.frequency, freq_range(1) * 1000, freq_range(2) * 1000);
    % add all calls in the range to one vector holding all calls 
    data = [data; calls(calls_inFrequency, :)];
end


