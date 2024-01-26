clc
clear

currentDepth = 1;
currPath = fileparts(mfilename('fullpath'));
fsep = filesep;
pos_v = strfind(currPath,fsep);
p = currPath(1:pos_v(length(pos_v)-currentDepth+1)-1);
addpath(p);
% parameter setting (MatchEIG)
thresh = 0.5; % MatchEIG

descs = {'HardNet' 'SoftMargin' 'SOSNet' 'CAPS'};
matchespath = '/matches/root/path/'; % matches root path
savepath = ''/matches/save/path/'; % matches save path

subdir =  dir(matchespath);

for dataseq = 3:length(subdir)
    datapath = [matchespath subdir(dataseq).name '/'];
    nextdir = dir( datapath );
    
    len = length(nextdir)-2;
    for nextseq = 1:len
        
        nextpath = [datapath nextdir(nextseq+2).name '/'];
        matchlist = [];
        min_pairs_num = 1200;
        for corrseq = 1:length(descs)
            dir_corrpairs = [nextpath descs{corrseq} '/'];
            matchdata = 'correspondence.mat';
            desc =  fullfile(dir_corrpairs, matchdata);
            load(desc);
            matches = sparse(matches);
            matchlist(:,:,corrseq) = matches;
            [m,~] = find(matches == 1);
            if length(m) < min_pairs_num
                min_pairs_num = length(m);
            end
        end
        d1 = size(matchlist,1); d2 = size(matchlist,2);
        n = 2*numel(descs);
        dimPerm = repmat([d1;d2],numel(descs),1);
        cumDim = [0; cumsum(dimPerm(1:end-1))];
        
        Tt = generateMatrixT(matchlist);
        T = sparse(Tt);
        
        %%
        d = min(min_pairs_num,1000); 
        f = 0; % 0: fsvd; 1: eigs;
        [~,Z_mvm] = MatchEIG(T,d,n,dimPerm,thresh,f);
%         [~,Z_mvm_1] = MatchEIG(Z_mvm,d,n,dimPerm,thresh,f);
%         [~,Z_mvm_2] = MatchEIG(Z_mvm_1,d,n,dimPerm,thresh,f);
        
        Apath = [savepath subdir(dataseq).name '/' nextdir(nextseq+2).name '/C2F/'];
        if ~exist(Apath); mkdir(Apath); end
%         Bpath = [savepath subdir(dataseq).name '/' nextdir(nextseq+2).name '/C2F+/'];
%         if ~exist(Bpath); mkdir(Bpath); end
%         Cpath = [savepath subdir(dataseq).name '/' nextdir(nextseq+2).name '/C2F++/'];
%         if ~exist(Cpath); mkdir(Cpath); end
        %% union C2F
        Rematchlist = GetOptimizationMatches_old(Z_mvm,numel(descs),cumDim,dimPerm,0);
        matches = zeros(d1,d2);
        for i=1:size(Rematchlist,2)
            matches(Rematchlist(1,i),Rematchlist(2,i)) = 1;
        end
        save([Apath,'correspondence.mat'],'matches');
        %% union C2F+
%         Rematchlist = GetOptimizationMatches_old(Z_mvm_1,numel(descs),cumDim,dimPerm,0);
%         matches = zeros(d1,d2);
%         for i=1:size(Rematchlist,2)
%             matches(Rematchlist(1,i),Rematchlist(2,i)) = 1;
%         end
%         save([Bpath,'correspondence.mat'],'matches');
        %% union C2F++
%         Rematchlist = GetOptimizationMatches_old(Z_mvm_2,numel(descs),cumDim,dimPerm,0);
%         matches = zeros(d1,d2);
%         for i=1:size(Rematchlist,2)
%             matches(Rematchlist(1,i),Rematchlist(2,i)) = 1;
%         end
%         save([Cpath,'correspondence.mat'],'matches');
    end
    fprintf('%d/575\n',nextseq+(dataseq-3)*5);
end
