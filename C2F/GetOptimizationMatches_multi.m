function out = GetOptimizationMatches_multi(Z,numdesc,cumDim,dimPerm,flag,m,n,imagepair)
%%-----------------input---------------
% Z : 优化后的 V
% numdesc :  特征数量
% cumDim : 每个小矩阵的起始位置
% dimPerm : 每个小矩阵的长度
% flag : 0：并集 1：交集
% m : 要找的第m个图像与第n个图像
%%--------------output---------
% Rematchlist: 匹配的矩阵
%----------------------------
After = cell(numdesc,1);

t=1;
for i = m:imagepair:imagepair*numdesc
    j = i+n-m;
    After{t,1} = Z(1+cumDim(i):cumDim(i)+dimPerm(i),1+cumDim(j):cumDim(j)+dimPerm(j));
    t = t+1;
end
%% 
%flag = 0; % 0:union 1: intersect
Rematchlist = []; 
if flag == 0
    out = After{1,1};
    for i = 2:numdesc
        out = out + After{i,1};
    end
    out(out > 0) = 1;
    
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