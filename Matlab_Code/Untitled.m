testChilds = {tempLines(:).childBuses};

lengthChilds= cellfun(@(x) length(x), testChilds);
lengthChildsUn = cellfun(@(x) length(unique(x)), testChilds);

difidx= find(lengthChilds-lengthChildsUn)