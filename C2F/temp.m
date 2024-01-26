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
timeall = 0;
descs = {'CAPS' 'SoftMargin' 'HardNet' 'SOSNet'};
DOG_POINT = 2000; % 只改这里
matchespath = '/media/sun-cug/EBD0A03DFF092445/YJH/CodeArrangement/C2F/Data/Matching/HPatches_DOG4000/'; % matches root path
savepath = ['/media/sun-cug/EBD0A03DFF092445/ZLY/DOG/DOG' num2str(DOG_POINT) '/']; % matches save path
if ~exist(savepath); mkdir(savepath); end

subdir =  dir(matchespath);

for dataseq = 3:length(subdir)
    datapath = [matchespath subdir(dataseq).name '/'];
    nextdir = dir( datapath );
    
    len = length(nextdir)-2;
    for nextseq = 1:len
        tic;
        nextpath = [datapath nextdir(nextseq+2).name '/'];
        matchlist = [];
        %% point
        points_per = DOG_POINT;
        min_pairs_num = DOG_POINT;
        for corrseq = 1:length(descs)
            dir_corrpairs = [nextpath descs{corrseq} '/'];
            matchdata = 'correspondence.mat';
            desc =  fullfile(dir_corrpairs, matchdata);
            load(desc);
            len1 = size(matches);
            num_points = min(min(len1(1),len1(2)),DOG_POINT);
            matches = sparse(matches(1:num_points,1:num_points));
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
        
        %% point
        d = min(min_pairs_num,DOG_POINT); 
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
        timeall = timeall+ toc;
        
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
    fprintf('time: %f\n', timeall);
end
