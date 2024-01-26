function T = generateMatrixT_multi(matchunion,num)
% ...............................input.....................................
% matchlist：输入的两两图像P种特征的排列矩阵
% num: 输入的多视图个数
% ...............................output....................................
% T：大矩阵
% .........................................................................


[descs,~] = size(matchunion);
desc_len=[];
% T的对角阵
T1=[];
P2_size=0;
for i = 1:descs
    P = []; %T的一行
    matchlist1 = matchunion{i,2}; %进入第i个特征的对应关系集合
    for j = 1:descs %进入第j个特征的对应关系集合
        P2=[];
        if i==j % 对角矩阵
            for m = 1:num
                P1=[];
                for n = 1:num
                    if m == n %第m张图像上的某特征点至少有另一张图像的对应
                        [row,~] = size(matchlist1{(m-1)*(num-1)+1,2});
                        p = zeros(row);
                        for k = (m-1)*(num-1)+1:m*(num-1)
                            Z1 = matchlist1{k,2};
                            p = p + Z1*Z1';
                            [desc_len(m),~] = size(Z1); 
                        end
                        p(find(p>0))=1;
                    else
                        Z1 = matchlist1{(num-1)*(m-1)+n-(n>m),2};
                        p = Z1;
                    end
                    P1=[P1,p];
                end
                P2=[P2;P1];
                P2_size = length(P1);
            end
        else   
            P2 = zeros(P2_size);
        end
        P=[P,P2];
    end
    T1=[T1;P];
end

desc_len = desc_len';
begin_num = [0; cumsum(desc_len(1:end-1))];

%T的非对角阵
T2 = [];
for i = 1:descs
    P = []; %T的一行
    matchlist1 = matchunion{i,2}; %进入第i个特征的对应关系集合
    for j = 1:descs
        matchlist2 = matchunion{j,2}; %进入第j个特征的对应关系集合
        P2=[];
        if i<j % 上三角
            for m = 1:num
                P1=[];
                for n=1:num
                    if m == n
                        Z1 = T1((i-1)*P2_size+begin_num(m)+1:(i-1)*P2_size+begin_num(m)+desc_len(m),(i-1)*P2_size+begin_num(m)+1:(i-1)*P2_size+begin_num(m)+desc_len(m));
                        Z2 = T1((j-1)*P2_size+begin_num(m)+1:(j-1)*P2_size+begin_num(m)+desc_len(m),(j-1)*P2_size+begin_num(m)+1:(j-1)*P2_size+begin_num(m)+desc_len(m));
                        p = Z1.*Z2;
                    else
                        Z1 = matchlist1{(num-1)*(m-1)+n-(n>m),2};
                        Z2 = matchlist2{(num-1)*(m-1)+n-(n>m),2};
                        p = Z1.*Z2;
                    end
                    P1=[P1,p];
                end
                P2=[P2;P1];
            end
        else % 其它
            P2 = zeros(P2_size);
        end
        P=[P,P2];
    end
    T2=[T2;P];
end
% 对称化
T = T1 + T2 + T2';

end