clc
clear
%'r2d2' 'geodesc' 'SuperPoint'
descs = {'caps' 'SOSNet' 'dynamicsmp' 'hardnet'}; 

pairspath = '/matches/root/path/'; % matches root path
savepath = '/matches/save/path/'; % matches save path

subdir =  dir( pairspath ); 

for dataseq = 3:length(subdir)

    datapath = [pairspath subdir(dataseq).name '\'];
    nextdir = dir( datapath );
    
    for nextseq = 1:length(nextdir)-2
        nextpath = [datapath nextdir(nextseq+2).name '\'];
        
        matchlist = [];
        for d = 1:length(descs)
            lastpath = [nextpath descs{d} '\correspondence.mat'];
            load(lastpath);
            
            matchlist(:,:,d) = matches;
        end
        
        % Un,In,Vo
        matches = sum(matchlist,3);
        matches(matches<=2) = 0;
        matches(matches>2) = 1;
        
        Apath = [savepath subdir(dataseq).name '\' nextdir(nextseq+2).name '\C2F-Vot\']; % save path
        if ~exist(Apath); mkdir(Apath); end
        save([Apath,'correspondence.mat'],'matches');
        
    end
     fprintf('%d/115 \n',dataseq-2)
end
