function [tempLines] = addAllDownstream(Lines, Transformers)
%ADDALLDOWNSTREAM Uses Lines from getLineInfo and Transfomers from
%getTransformerInfo to find all down stream buses and elements

%DJM 7-22-2015

%struct only needed and pull in transformer and line data
%Transformers = getTransformerInfo(DSSCircObj);

tempLines = Lines;
%variable to keep track of names and position of names in tempLines and Transformers struct
tempNames = {Lines(:).name};
TransNames = {Transformers(:).name};

numLines= length(tempLines);
%Initialize the new field in tempLines
for ii = 1:length(tempNames)
    %add field to keep track of the index in the original tempLines struct
    tempLines(ii).idx = ii;
    tempLines(ii).childElements = [];
    tempLines(ii).childBuses = [];
    tempLines(ii).childName = [];
end

%Initialize NeedUpstream array to keep track of where traced paths
%intersect in initial pass
NeedUpstream = [];

%Initialize a list of the lines which have not yet been traced for initial
%pass
Untraced = 1:length(tempLines);



while (~isempty(Untraced))
%do this until we have traced all lines and buses once

%subset tempLines by Lines which have not been traced
UntracedLines = tempLines(Untraced);

%find the line (by bus2) which is fathest from the source
%idx is the index of line in tempLines 
[D2, UnIdx] = max([UntracedLines(:).bus2Distance]);

%idx keeps track of the idx of the bus which is currently being examined
%updated in each iteration to trace circuit
idx = UntracedLines(UnIdx).idx;

    %D1 is the distance to the sending bus of current line
    D1 = UntracedLines(UnIdx).bus1Distance;

    %Initialize variables to hold previous buses in each trace through the
    %cricuit
    preName = [];
    preBuses = {};
    preNames = {};
    curName = tempLines(idx).name;
    %Trace path starting at the furthest line which has not been traced
    while ((ismember(idx,Untraced)) && (D1 > 0))
      
        %Update list of indices of traced lines by removing the index of
        %the current line
        Untraced = Untraced(Untraced~=idx);
        
        %Find name of current bus and remove the indication of the phases
        %in the names
        curBus = tempLines(idx).bus2;
        curBus = curBus(1:strfind(curBus,'.')-1);
    
        tempLines(idx).childElements = union(tempLines(idx).childElements, preNames) ;
        tempLines(idx).childBuses = union(union(tempLines(idx).childBuses, preBuses), curBus) ;
        tempLines(idx).childName = preName ;
    
        preBuses = tempLines(idx).childBuses;
    
        preName = curName;
        preNames = [preNames; preName];
        curName = tempLines(idx).parentObject;
        curName = curName(strfind(curName,'.')+1:end);
        %update idx for parent HERE
        idx = find(strcmp(curName, tempNames));

        if isempty(idx) && ismember(curName,TransNames)
            TransIdx = find(strcmp(TransNames,curName));
            TransBus1 = regexprep(Transformers(TransIdx).bus1,'(\.[0-9]+)','');
            TransBus2 = regexprep(Transformers(TransIdx).bus2,'(\.[0-9]+)','');  

            preBuses = [preBuses; TransBus2];
            idx = find(strcmp(TransBus1, regexprep({tempLines(:).bus2},'(\.[0-9]+)','')));
        end
        D1 = tempLines(idx).bus1Distance;
    end

    if D1~=0
        NeedUpstream = [NeedUpstream idx];
    end

    Untraced = Untraced(Untraced~=idx);

    tempLines(idx).childElements = union(tempLines(idx).childElements, preNames) ;
    tempLines(idx).childBuses = union(tempLines(idx).childBuses, preBuses) ;
    tempLines(idx).childName = preName ;

    end


    %sort upstream buses
    UpstreamLines= tempLines(NeedUpstream);
    [Sort ,UpSortIdx] = sort([UpstreamLines(:).bus2Distance],'descend');
    UpstreamLines = UpstreamLines(UpSortIdx);
    for ii = 1:length(UpstreamLines)
        idx = UpstreamLines(ii).idx;
        preBuses = [];
        preNames = [];
        preName = {};
        FirstIter = true;

    while (~ismember(idx,NeedUpstream) && (D1>0) || FirstIter)
        FirstIter = false;
        curBus = tempLines(idx).bus2;
        curBus = curBus(1:strfind(curBus,'.')-1);
        tempLines(idx).childElements = union(tempLines(idx).childElements, preNames) ;
        tempLines(idx).childBuses = union(tempLines(idx).childBuses, preBuses) ;
        preNames = tempLines(idx).childElements ;
        preBuses = tempLines(idx).childBuses ;
        curName = tempLines(idx).parentObject;
        curName = curName(strfind(curName,'.')+1:end);
        %update idx for parent HERE
        idx = find(strcmp(curName, tempNames));
        %how do we handle transformers?
        if isempty(idx) && ismember(curName,TransNames)
            TransIdx = find(strcmp(TransNames,curName));
            TransBus1 = regexprep(Transformers(TransIdx).bus1,'(\.[0-9]+)','');
            TransBus2 = regexprep(Transformers(TransIdx).bus2,'(\.[0-9]+)','');
            preBuses = [preBuses; TransBus2];
            idx = find(strcmp(TransBus1, regexprep({tempLines(:).bus2},'(\.[0-9]+)','')));
        end
        
        D1 = tempLines(idx).bus1Distance;
    end
    
    tempLines(idx).childElements = union(tempLines(idx).childElements, preNames) ;
    tempLines(idx).childBuses = union(tempLines(idx).childBuses, preBuses) ;
    end

end