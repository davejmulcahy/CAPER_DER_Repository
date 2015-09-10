% Script to run brute force PV hosting capacity

%comserver should be editted to include appropriate file paths
comserver

 DSSCircObj.AllowForms=false;

% Get 3 phase buses or more generally filter buses
Buses=getBusInfo(DSSCircObj);
tempBuses=Buses([Buses.numPhases]==3);
tempBuses=tempBuses([tempBuses.distance]>1.5);

% Initialize cell array for transformer taps
originalTaps=cell(DSSCircuit.Transformers.Count,1);

% Get Transformer Info
Transformers = getTransformerInfo(DSSCircObj);
XfmrTaps = struct();
xfmrName=DSSCircuit.Transformers.AllNames;
[XfmrTaps(:).names] = xfmrName{:};
nXfmrs = DSSCircuit.Transformers.Count;

% Run load flow for base case with light load
DSSText.command ='solve loadmult=0.3';
% Get base case taps for regulators
for jj=1:DSSCircuit.Transformers.Count
    DSSText.command = sprintf('? RegControl.%s.TapNum',char(xfmrName(jj)));
    originalTaps(jj) = {DSSText.result};
end


% Place a new dummy PV to be edited in the for loop
DSSText.command = sprintf('new generator.PV bus1=%s phases=3  kv=%d kw=%d pf=1 enabled=true',tempBuses(1).name,0,0); 

% Create variable of bus names at which to place PV
busNames = {tempBuses().name};
VoltagesAll = struct();
[VoltagesAll(:).names] = busNames{:};

VoltagesMax = {};

for jj = 1:nXfmrs
    XfmrTaps(jj).Taps = cell(length(tempBuses),200);
end

    for pp = 4:length(Transformers)
        DSSText.command = ['edit regcontrol.' Transformers(pp).name ' vreg=125'];
    end

%PV Sweep .1 - 10 MW
time=tic;
h = waitbar(0,'0%');
for ii=1:length(tempBuses)
    
    for i= 1:100
        MW = i*100;
        % Set regulators to base case taps
        for ij=1:DSSCircuit.Transformers.Count;
            DSSText.command= sprintf('edit RegControl.%s Tapnum=%s',char(xfmrName(ij)),char(originalTaps(ij)));
        end
        
        % Set up PV, solve with 30% load
        DSSText.command = sprintf('edit generator.PV bus1=%s phases=3  kv=%d kw=%d pf=1 enabled=true',tempBuses(ii).name,tempBuses(ii).kVBase,MW); 
        DSSText.command = 'solve loadmult=0.3';

        % After solving get all bus voltages PU in the circuit
        Voltages=DSSCircuit.AllBusVmagPu;
        % Get rid of weird voltages
        Voltages=Voltages(Voltages ~= 0);
        Voltages=Voltages(Voltages > .5);
        
%         for jj=1:nXfmrs
%             DSSText.command = sprintf('? RegControl.%s.TapNum',char(xfmrName(jj)));
%             XfmrTaps(jj).Taps(ii,i) = {DSSText.result};
%         end
        
        VoltagesAll(ii).(['MW_',num2str(MW)]) = Voltages;
        VoltagesMax(ii).(['MW_',num2str(MW)]) = max(Voltages(4:end));
        % Stops increasing PV when max voltage is over 1.08
        if max(Voltages) > 1.08
            break
        end
           
    end
    
    waitbar(ii/length(tempBuses),h,sprintf('Percent Buses Completed: %0.1f %% \n time elapsed: %0.1f',ii/length(tempBuses)*100, toc(time)));
end
toc(time)

% Variable for field names/PV penetration
tempFNames = fieldnames(VoltagesMax);

% replace empty max voltages with dummy 
% fills in blanks which were not run
for ii = 1:length(tempFNames)
    tempidx = cellfun(@(x) isempty(x), {VoltagesMax.(tempFNames{ii})});
    emptyidx = find(tempidx);
    for jj = 1:length(emptyidx)
        VoltagesMax(emptyidx(jj)).(tempFNames{ii}) = 99;
    end
    
end

% Optional line to savle data from analysis
save('commonwealth.mat', 'VoltagesAll', 'VoltagesMax');

figure(2)
hold off
tempFNames = fieldnames(VoltagesMax);
% tempFNames = tempFNames(regexp(fieldnames(VoltagesMax),'MW_'));
for ll = 1:length(tempFNames)
    tempdata = [VoltagesMax.(tempFNames{ll})];
    y = str2double(regexprep(tempFNames{ll},'MW_',''))/1000;
    q1 = quantile(tempdata',.25);
    q2 = quantile(tempdata',.5);
    q3 = quantile(tempdata',.75);
    
    
    x1 = tempdata(tempdata<q1);
    x2 = tempdata((tempdata<q2) & (tempdata>=q1));
    x3 = tempdata(tempdata<q3 & tempdata>=q2);
    x4 = tempdata(tempdata>=q3);
    plot(ones(length(x1),1)*y, x1, 'xg ');
    if ll == 1
        hold on
    end
    plot(ones(length(x2),1)*y, x2, 'xb ');
    plot(ones(length(x3),1)*y, x3, 'xy ');
    plot(ones(length(x4),1)*y, x4, 'xr ')
    
end

ylim([1.045,1.08])
xlabel('Penetration (MW)')
ylabel('Max Voltage (pu)')
legend('1st Quartile', '2nd Quartile', '3rd Quartile', '4th Quartile', 'ANSI Limit')

hold off
