%find downstream elements


tic
tempNames = {Lines(:).name};
Transformers = getTransformerInfo(DSSCircObj);
TransNames = {Transformers(:).name};
tempLines = Lines;
numLines= length(tempLines);

for ii = 1:length(tempNames)
    tempLines(ii).idx = ii;
    tempLines(ii).childElements = [];
    tempLines(ii).childBuses = [];
    tempLines(ii).childName = [];
    
end

NeedUpstream = [];
Untraced = 1:length(tempLines);

[maxD2, maxD2idx] = max([tempLines.bus2Distance]);


%DJM How should be keep of Names new struct of "Children.(name)" easy to
%reference by name

%keeps track of active name
curName = tempLines(maxD2idx).name;
children.(curName).parent = curName;
D1 = tempLines(maxD2idx).bus1Distance;
idx = maxD2idx;
%
%alternatively, we couold add to Lines Struct
preName = [];
LinesKnown = [];
preBus = [];
preBuses = {};

i = 0;
jj = 0;
while (~isempty(Untraced))
    jj=jj+1;
%do this until we have traced all lines
    UntracedLines = tempLines(Untraced);
    [D1, UnIdx] = max([UntracedLines(:).bus2Distance]);
    idx = UntracedLines(UnIdx).idx;
    preName = [];
    preBus = [];
    preBuses = {};
    preNames = {};
    
    
    while ((ismember(idx,Untraced)) && (D1 > 0))
        i = i+1; %TEMP for counting and troubleshooting
        Untraced = Untraced(Untraced~=idx);
        LinesKnown = [LinesKnown idx];
        
        
        curBus = tempLines(idx).bus2;
        curBus = curBus(1:strfind(curBus,'.')-1);
        preBuses = [preBuses; curBus];
        
        tempLines(idx).childElements = [tempLines(idx).childElements; preNames] ;
        tempLines(idx).childBuses = [tempLines(idx).childBuses; preBuses] ;
        tempLines(idx).childName = preName ;
        
        preName = curName;
        preNames = [preNames; preName];
        
        curName = tempLines(idx).parentObject;
        curName = curName(strfind(curName,'.')+1:end);
        
        
        %update idx for parent HERE
        idx = find(strcmp(curName, tempNames));
        %how do we handle transformers?
        
        if isempty(idx) && ismember(curName,TransNames) 
            
            TransIdx = find(strcmp(TransNames,curName));  
            TransBus1 = regexprep(Transformers(TransIdx).bus1,'(\.[0-9]+)','');
            preBuses = [preBuses; TransBus1];

            idx = find(strcmp(TransBus1, regexprep({tempLines(:).bus2},'(\.[0-9]+)','')));
            
        end
        
            D1 = tempLines(idx).bus1Distance;

    end
    
    
    if D1~=0
        NeedUpstream = [NeedUpstream idx];
    end
    
        Untraced = Untraced(Untraced~=idx);
        LinesKnown = [LinesKnown idx];
        
        tempLines(idx).childElements = [tempLines(idx).childElements; preNames] ;
        tempLines(idx).childBuses = [tempLines(idx).childBuses; preBuses] ;
        tempLines(idx).childName = preName ;
    
    %NOW i need to take the remaining buses upstream


end
   
%sort upstream buses
UpstreamLines= tempLines(NeedUpstream)
[Sort ,UpSortIdx] = sort([UpstreamLines(:).bus2Distance],'descend');

UpstreamLines = UpstreamLines(UpSortIdx);

for ii = 1:length(UpstreamLines)
    idx = UpstreamLines(ii).idx;
    preBuses = [];
    preNames = [];
    preName = [];
    FirstIter = true;
    while (~ismember(idx,NeedUpstream) && (D1>0) || FirstIter)
        FirstIter = false;
        curBus = tempLines(idx).bus2;
        curBus = curBus(1:strfind(curBus,'.')-1);
        
        tempLines(idx).childElements = [tempLines(idx).childElements; preNames] ;
        tempLines(idx).childBuses = [tempLines(idx).childBuses; preBuses] ;
        preNames = tempLines(idx).childElements ;
        preBuses = tempLines(idx).childBuses ;
        
        preNames = [preNames; preName];
        curName = tempLines(idx).parentObject;
        curName = curName(strfind(curName,'.')+1:end);
        
        %update idx for parent HERE
        idx = find(strcmp(curName, tempNames));
        %how do we handle transformers?
        
        if isempty(idx) && ismember(curName,TransNames) 
            
            TransIdx = find(strcmp(TransNames,curName));  
            TransBus1 = regexprep(Transformers(TransIdx).bus1,'(\.[0-9]+)','');
            preBuses = [preBuses; TransBus1];

            idx = find(strcmp(TransBus1, regexprep({tempLines(:).bus2},'(\.[0-9]+)','')));
            
        end
        
            D1 = tempLines(idx).bus1Distance;

        
    end

end
% 
% %probably unnecessary
%     while ~isempty(NeedUpstream)
%         prevUpstream = NeedUpstream;
%         NeedUpstream = [];
%         
%         UpstreamLines = tempLines(NeedUpstream);
%         [D1, UpIdx] = max([UpstreamLines(:).bus2Distance]);
%         idx = UntracedLines(UpIdx).idx;
%         preName = [];
%         preBus = [];
%         preBuses = {};
%         preNames = {};
%         
%         while ((~ismember(idx,PrevUpstream)) && (D1 > 0))
%             i = i+1; %TEMP for counting and troubleshooting
%             Untraced = Untraced(Untraced~=idx);
% %             LinesKnown = [LinesKnown idx];
%         
%         
%             curBus = tempLines(idx).bus1;
%             curBus = curBus(1:strfind(curBus,'.')-1);
%         
%             preBuses = [preBuses; curBus];
%             
%             tempLines(idx).childElements = [tempLines(idx).childElements preNames] ;
%             tempLines(idx).childBuses = [tempLines(idx).childBuses preBuses] ;
%             tempLines(idx).childName = preName ;
%         
%             preName = curName;
%             preNames = [preNames; preName];
%             curName = tempLines(idx).parentObject;
%             curName = curName(strfind(curName,'.')+1:end);
%         
%         
%         %update idx for parent HERE
%         idx = find(strcmp(curName, tempNames));
%         %how do we handle transformers?
%         
%         if isempty(idx) && ismember(curName,TransNames) 
%             
%             TransIdx = find(strcmp(TransNames,curName));  
%             TransBus1 = regexprep(Transformers(TransIdx).bus1,'(\.[0-9]+)','');
%             preBuses = [preBuses; TransBus1];
% 
%             idx = find(strcmp(TransBus1, regexprep({tempLines(:).bus2},'(\.[0-9]+)','')));
%             
%         end
%         
%     end






%  for ii = 1:length(tempNames)
%      tempLines(ii).childBuses = unique(tempLines(ii).childBuses);
%      tempLines(ii).childLines = unique(tempLines(ii).childLines);
% end
toc