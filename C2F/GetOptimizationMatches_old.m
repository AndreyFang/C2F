function Rematchlist = GetOptimizationMatches_old(Z,numdesc,cumDim,dimPerm,flag)

After = cell(numdesc,1);
for i = 1:2:2*numdesc
    j = i+1;
    After{(i+1)/2,1} = Z(1+cumDim(i):cumDim(i)+dimPerm(i),1+cumDim(j):cumDim(j)+dimPerm(j));
end
%% 
%flag = 0; % 0:union 1: intersect
Rematchlist = []; 
if flag == 0
    for i=1:numdesc
        temp = After{i,1};
        
        [row,col] = find(temp ~= 0);
        Rematchlist = [Rematchlist;[row,col]];
        
    end
    Rematchlist = Rematchlist';
    %%
    [~, m, ~]=unique(Rematchlist(1:2,:)','rows','stable'); 
    Rematchlist=Rematchlist(:,m);
    [~, m, ~]=unique(Rematchlist(1,:)','rows','stable'); 
    Rematchlist=Rematchlist(:,m);
    [~, m, ~]=unique(Rematchlist(2,:)','rows','stable'); 
    Rematchlist=Rematchlist(:,m);
else
    [row,col] = find(After{1,1} ~= 0);
    Rematchlist = [Rematchlist;[row,col]];
  
    for i=2:numdesc
        temp = After{i,1};
        
        [row,col] = find(temp ~= 0); AA = [row,col];
        
        [~,ia,ib] = intersect(AA(:,1),Rematchlist(:,1)); 
        AA = AA(ia,:); Rematchlist = Rematchlist(ib,:);
        [~,ia,ib] = intersect(AA(:,2),Rematchlist(:,2)); 
        AA = AA(ia,:); Rematchlist = Rematchlist(ib,:);
        
    end
    Rematchlist = Rematchlist';
end