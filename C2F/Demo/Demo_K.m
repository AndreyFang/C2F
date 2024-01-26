clc
clear

currentDepth = 1;
currPath = fileparts(mfilename('fullpath'));
fsep = filesep;
pos_v = strfind(currPath,fsep);
p = currPath(1:pos_v(length(pos_v)-currentDepth+1)-1);
addpath(p);
% parameter setting (MatchEIG)
thresh = 0.5;

 f = 1; %0: fsvd; 1: matlab eigs
descs = {'hardnet' 'SOSNet' 'dynamicsmp' 'caps'};

pairspath = '/matches/root/path/'; % matches root path
savepath = ''/matches/save/path/'; % matches save path
timesave = '~\C2F\Data\Results\K\Eigs\'; % time save path

subdir =  dir( pairspath );
times = cell(10,1);
num = 1;

for dataseq = [11 15 31 60 71 94 103 104 107 112]
    datapath = [pairspath subdir(dataseq).name '\'];
    nextdir = dir( datapath );
    times_sub = [];
    
    len = length(nextdir)-2;
    for nextseq = 1:len
        
        nextpath = [datapath nextdir(nextseq+2).name '\'];
        
        matchlist = [];
        min_pairs_num = 1800;
        for corrseq = 1:length(descs)
            dir_corrpairs = [nextpath descs{corrseq} '\'];
            matchdata = 'correspondence.mat';
            desc =  fullfile(dir_corrpairs, matchdata);
            P = load(desc);
            matchlist(:,:,corrseq) = P.matches;
            [m,~] = find(P.matches == 1);
            if length(m) < min_pairs_num
                min_pairs_num = length(m);
            end
        end
        
        d1 = size(matchlist,1); d2 = size(matchlist,2); %
        n = 2*numel(descs); %
        dimPerm = repmat([d1;d2],numel(descs),1);
        cumDim = [0; cumsum(dimPerm(1:end-1))];
        %%
        T = generateMatrixT(matchlist); %
        T = sparse(T);
        %%
        d = 2000;
        
        ti = zeros(1,d/50);
        for k = 50:50:d
            tic
            [~,Z_mvm] = MatchEIG(T,k,n,dimPerm,thresh,f);
            time_match = toc;
            ti(k/50) = ti(k/50) + time_match;
            
            Apath = [savepath subdir(dataseq).name '\' nextdir(nextseq+2).name '\' num2str(k) '\'];
            if ~exist(Apath); mkdir(Apath); end
            
            %% union
            Rematchlist = GetOptimizationMatches_old(Z_mvm,numel(descs),cumDim,dimPerm,0);
            matches = zeros(d1,d2);
            for i=1:size(Rematchlist,2)
                
                matches(Rematchlist(1,i),Rematchlist(2,i)) = 1;
                
            end
            save([Apath,'correspondence.mat'],'matches');
            fprintf('scene:%d; pairs:%d; K:%d .\n',num,nextseq,k);
        end
        times_sub = [times_sub; ti];   
    end
    times{num,1} = times_sub;
    num = num + 1;
end

save([timesave 'times.mat'],'times');