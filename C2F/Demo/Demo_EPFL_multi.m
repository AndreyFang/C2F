clc
clear

currentDepth = 1;
currPath = fileparts(mfilename('fullpath'));
fsep = filesep;
pos_v = strfind(currPath,fsep);
p = currPath(1:pos_v(length(pos_v)-currentDepth+1)-1);
addpath(p);
addpath('./Evaluation Function/');
% parameter setting (MatchEIG)
thresh = 0.25;

descs = {'SOSNet' 'caps' 'hardnet' 'dynamicsmp'};
pairspath = '/matches/root/path/'; % matches root path
kptspath = '~/IntegrateData/superpoint/EPFL/'; % integrate data root path
imgroot = '~/Image_dataset/EPFL/'; % dataset root path

subdir =  dir(pairspath);

matrixtime_all = 0;
opttime_all = 0;
time_set = cell(3,2);
correctfinalRate = cell(length(subdir)-2,3);

for dataseq = 3:length(subdir)
    correctfinalRate{dataseq-2,1} = subdir(dataseq).name;
    imagedatasetpath = [imgroot subdir(dataseq).name '/025/'];
    image_num = length(dir([imagedatasetpath '*.jpg']));
    datapath = [pairspath subdir(dataseq).name '/'];
    
    kptsnextpath = [kptspath subdir(dataseq).name '/'];
    
    timesavefullpath = [timesavepath subdir(dataseq).name '/'];
    
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
            min_pairs_num = 2000;
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
    
    
    %
    d1 = size(matchlist,1);
    d2 = size(matchlist,2);
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
    %%
    tic;
    Tt = generateMatrixT_multi(matchunion,image_num);
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
    correctRate = zeros(image_num,image_num);
    correctpairs = 0;
    for i = 1:image_num
        for j = i+1:image_num
            Rematchlist = GetOptimizationMatches_multi(Z_mvm,numel(descs),cumDim,dimPerm,0,i,j,image_num);
            matches = zeros(size(Rematchlist));
            matches(Rematchlist>0)=1;
            %
            nextdir1 = dir([kptsnextpath '*.mat']);
            d1path = [kptsnextpath nextdir1(i).name];
            d1 = load(d1path);
            keypoints1 = d1.Image_Information.keypoints';
            P1 = d1.Image_Information.P;
            d2path = [kptsnextpath nextdir1(j).name];
            d2 = load(d2path);
            keypoints2 = d2.Image_Information.keypoints';
            P2 = d2.Image_Information.P;
            
            [m,n] = find(Rematchlist == 1);
            pts1 = keypoints1(m,:);
            pts2 = keypoints2(n,:);
            F = vgg_F_from_P(P1,P2);
            [corrRate,CorrectIndex] = my_evaluate_F(pts1,pts2,F);
            correctRate(i,j) = corrRate;
            correctRate(j,i) = corrRate;
            correctpairs = correctpairs+length(CorrectIndex);
            matches = matches';
        end
    end
    correctfinalRate{dataseq-2,2} = correctRate; % precision
    correctfinalRate{dataseq-2,3} = correctpairs;  
end
