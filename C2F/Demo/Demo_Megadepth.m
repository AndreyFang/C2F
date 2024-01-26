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

descs = {'HardNet' 'SoftMargin' 'SOSNet' 'CAPS'};
pairspath = '/matches/root/path/'; % matches root path
savepath = ''/matches/save/path/'; % matches save path

subdir = {'easy' 'moderate' 'hard'};

for dataseq = 1:length(subdir)
    
    datapath = [pairspath subdir{dataseq} '/'];
    nextdir = dir( datapath );
    
    for nextseq = 1:length(nextdir)-2
        
        nextpath = [datapath nextdir(nextseq+2).name '/'];

        matchlist = [];
        min_pairs_num = 1200;
        
        for corrseq = 1:length(descs)
            dir_corrpairs = [nextpath descs{corrseq} '/'];
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
        d = min(min_pairs_num,1000);
        f = 0; %0: fsvd; 1: matlab eigs
        tic
        [Z_handled,Z_mvm] = MatchEIG(T,d,n,dimPerm,thresh,f);
        time_match = toc;

        Apath = [savepath subdir{dataseq} '/' nextdir(nextseq+2).name  '/C2F/'];
        if ~exist(Apath); mkdir(Apath); end
        %% union
        Rematchlist = GetOptimizationMatches_old(Z_mvm,numel(descs),cumDim,dimPerm,0);
        matches = zeros(d1,d2);
        for i=1:size(Rematchlist,2)
            matches(Rematchlist(1,i),Rematchlist(2,i)) = 1;
        end
        save([Apath,'correspondence.mat'],'matches');
        
        fprintf('%d/3000 \n',nextseq+(dataseq-1)*1000)
    end
    
    
end
