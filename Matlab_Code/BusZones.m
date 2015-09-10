regNodes = {Transformers([Transformers(:).bus1NodeOrder]==1).bus2};
regNodes = regexprep(regNodes,'(\.[0-9]+)','');

linesBus1 = regexprep({Lines(:).bus1},'(\.[0-9]+)','');

for kk = 1:length(regNodes)
    reglinidx(kk) = find(strcmp(regNodes(kk),linesBus1));
end

Lines=addAllDownstream(Lines,Transformers);

LinesDown = Lines(reglinidx);
[ord, ordidx] =sort([LinesDown(:).bus1Distance] , 'descend');
LinesDown = LinesDown(ordidx);

for ll = 1:length(LinesDown)
diff{ll} = LinesDown(ll).childBuses ;
if ll ~=1
for pp = 1:ll-1
diff{ll} = setdiff(diff{ll}, LinesDown(pp).childBuses);
end
end
end



diffnames = 5:-1:1;
for mm = 1:length(Buses)
for pp = 1:length(diff)
if ismember(Buses(mm).name,diff{pp})
Buses(mm).Zone = diffnames(pp);
break
end
end
end

zone1idx = [Buses(:).Zone]==1;
zone2idx = [Buses(:).Zone]==2;
zone3idx = [Buses(:).Zone]==3;
zone4idx = [Buses(:).Zone]==4;
zone5idx = [Buses(:).Zone]==5;

ZoneRegs{1} = Transformers(1:3);
ZoneRegs{2} = Transformers(4:6);
ZoneRegs{3} = Transformers(10:12);
ZoneRegs{4} = Transformers(8:9);
ZoneRegs{5} = Transformers(7);
