fuseNames = DSSCircuit.Fuse.All;

LineNames = {tempLines.name};

fuseidx = cellfun(@(x) find(strcmp(x,LineNames)), fuseNames);

fuseDownBuses = {tempLines(fuseidx).childBuses};