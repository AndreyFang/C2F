clc
clear 

currentDepth = 1;
currPath = fileparts(mfilename('fullpath'));
fsep = filesep;
pos_v = strfind(currPath,fsep);
p = currPath(1:pos_v(length(pos_v)-currentDepth+1)-1);
addpath(p);
% parameter setting (MatchEIG)
thresh = 0.25;

descs = {'hardnet' 'SOSNet' 'dynamicsmp' 'caps'};
parispath = '/matches/root/path/'; % matches root path
savepath = ''/matches/save/path/'; % matches save path

subdir =  dir(parispath);

matrixtime_all = 0;
opttime_all = 0;
time_set = cell(3,2);

image_num = 6;%
for dataseq = 3:length(subdir)
    datapath = [parispath subdir(dataseq).name '/'];

    nextdir = dir( datapath );
    len = length(nextdir)-2;
    matchlist = [];

    matchunion = cell(length(descs),2);
   
    for corrseq = 1:length(descs)  
        matchcell = cell(len,2);
        for nextseq = 1:len
            matchunion{corrseq,1} = descs{corrseq};
            matchcell{nextseq,1} = nextdir(nextseq+2).name;           
            nextpath = [datapath nextdir(nextseq+2).name '/'];          
            min_pairs_num = 1200;
            dir_corrpairs = [nextpath descs{corrseq} '/'];
            matchdata = 'correspondence.mat';
            desc =  fullfile(dir_corrpairs, matchdata); 
            load(desc);
            matches = sparse(matches);
            
            matchcell{nextseq,2} = matches;
            
            [m,~] = find(matches == 1);
            if length(m) < min_pairs_num
                min_pairs_num = length(m);
            end
        end
        matchunion{corrseq,2} = matchcell;
    end
    
%     d1 = size(matchlist,1); d2 = size(matchlist,2);
    dimPerm = [];
    n = 2*numel(descs);
    for i=1:image_num-1
        if i==1
            [first,sec] = size(matchcell{i,2});
            dimPerm(i) = first;
            dimPerm(i+1) = sec;
        else
            [~,col] = size(matchcell{i,2});
            dimPerm(i+1) = col;
        end     
    end
    dimPerm = dimPerm';
    dimPerm = repmat(dimPerm,numel(descs),1); 
    cumDim = [0; cumsum(dimPerm(1:end-1))];
    tic;
    Tt = generateMatrixZ(matchunion,image_num); 
    T = sparse(Tt);   
    matrixtime = toc;
    matrixtime_all = matrixtime_all + matrixtime;
    %Rematchlist = GetOptimizationMatches_multi(T,numel(descs),cumDim,dimPerm,0,3,4,image_num);
    %%
    d = min(min_pairs_num,1000);  
    f = 0; %0: fsvd; 1: matlab eigs 
    tic
    [~,Z_mvm] = MatchEIG(T,d,image_num*numel(descs),dimPerm,thresh,0);

    time_match = toc;
    opttime_all = opttime_all + time_match;
    
    %% union
    for i = 2:image_num
        Rematchlist = GetOptimizationMatches_multi(Z_mvm,numel(descs),cumDim,dimPerm,0,1,i,image_num);
        matches = zeros(size(Rematchlist));
        matches(Rematchlist>0)=1;
        
        Apath = [savepath subdir(dataseq).name '/' nextdir(i+1).name '/matcheig_hardnet/']; % save path
        if ~exist(Apath); mkdir(Apath); end
        save([Apath,'correspondence.mat'],'matches');  
    end
    
end