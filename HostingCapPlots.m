%make plot of hosting capacities with quartiles 
%Also calculates quartiles to be used for boxplots

figure(3)
hold off
tempFNames = fieldnames(VoltagesMax);
%tempFNames = tempFNames(regexp(fieldnames(VoltagesMax),'MW_'));
x1 = [];
x2 = [];
x3 = [];
x4 = [];
y1 = [];
y2 = [];
y3 = [];
y4 = [];

qtags(1:5) = 0;


for ll = 1:length(tempFNames)
    tempdata = [VoltagesMax.(tempFNames{ll})];
    
    y = str2double(regexprep(tempFNames{ll},'MW_',''))/1000;
    q1(ll) = quantile(tempdata',.25);
    q2(ll) = quantile(tempdata',.5);
    q3(ll) = quantile(tempdata',.75);
    
    newx1 = tempdata(tempdata<q1(ll));
    newx2 = tempdata((tempdata<q2(ll)) & (tempdata>=q1(ll)));
    newx3 = tempdata(tempdata<q3(ll) & tempdata>=q2(ll));
    newx4 = tempdata(tempdata>=q3(ll));
    x1 = [x1, newx1];
    x2 = [x2, newx2];
    x3 = [x3, newx3];
    x4 = [x4, newx4];

    y1 = [y1, ones(1,length(newx1))*y];
    y2 = [y2, ones(1,length(newx2))*y];
    y3 = [y3, ones(1,length(newx3))*y];
    y4 = [y4, ones(1,length(newx4))*y];
    
    
end

    plot(y1, x1, 'xg ');
    hold on
    plot(y2, x2, 'xb ');
    plot(y3, x3, 'xy ');
    plot(y4, x4, 'xr ');
    
    

ylim([1.045,1.07])
xlabel('Penetration (MW)')
ylabel('Max Voltage (pu)')
plot([0,10],[1.05, 1.05],'k-');


%find quartile hosting capacity
quartHosting(1) = y4(find(x4>1.05, 1, 'first'));
quartHosting(2) = y3(find(x3>1.05,1,'first'));
quartHosting(3) = y2(find(x2>1.05,1,'first'));
quartHosting(4) = y1(find(x1>1.05,1, 'first'));

ygroups = unique(y4);
for ll = 1:length(ygroups)
    
    
    tempX = x1(y1==ygroups(ll));
    
    nX = length(tempX);
    count = sum(tempX>1.05);
    
    if nX == count
        quartHosting(5) = ygroups(ll)
        break
    end
    
end


qhColors = {'k--', 'k--', 'k--', 'k--', 'k--'};
quartNames = {'Min', '25%', '50%', '75%', 'Max'};

for kk = 1:length(quartHosting)
 
    plot([quartHosting(kk) quartHosting(kk)], [1 1.08], qhColors{kk}, 'LineWidth', 2)
    text(quartHosting(kk),1.0705,quartNames{kk}, 'FontWeight', 'bold', 'FontSize', 12)
end



legend('1st Quartile', '2nd Quartile', '3rd Quartile', '4th Quartile', 'ANSI Limit', 'Hosting Capacities')
hold off