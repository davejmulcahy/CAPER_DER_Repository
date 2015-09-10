
dssCodePath = 'D:\NCSU Research\Duke Circuits\';
circuitPath = [dssCodePath,'commonwealth\run_master_allocate.dss'];

% String used to compile circuit
str = ['''',circuitPath,''''];

% Add paths for locations of Matlab code and gridPV
addpath([dssCodePath,'Matlab_Code']);
addpath([dssCodePath,'Matlab_Code\GridPV']);
addpath([dssCodePath,'Matlab_Code\GridPV\subfunctions']);

% 1. Start the OpenDSS COM. Needs to be done each time MATLAB is opened     
[DSSCircObj, DSSText] = DSSStartup; 
    
% 2. Compiling the circuit     
DSSText.command = ['Compile ' str]; 

% 3. Solve the circuit. Call anytime you want the circuit to resolve     
DSSText.command = 'solve'; 

% 4. Run circuitCheck function to double-check for any errors in the circuit before using the toolbox     
%warnSt = circuitCheck(DSSCircObj);

DSSCircuit = DSSCircObj.ActiveCircuit;

Lines=getLineInfo(DSSCircObj);

