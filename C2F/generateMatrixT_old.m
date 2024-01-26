function T = generateMatrixT_old(matchlist)
% 根据M×P排列矩阵计算（M*P*2）×（M*P*2）大矩阵
% ...............................input.....................................
% matchlist：输入的P种特征的排列矩阵
% ...............................output....................................
% T：大矩阵
% .........................................................................
d1 = size(matchlist,2);
d2 = size(matchlist,1);
Z = sort(randperm(d1));

T = [];
for i = 1:d2
    P = []; % 记录第i个特征点对关系对应于第j个特征点对关系的排列矩阵(比如sift和rsift之间)
    Z1 = [Z;matchlist(i,:)]; % 第i个特征的点对关系
    for j=1:d2
        Z2 = [Z;matchlist(j,:)]; % 第j个特征的点对关系
        p1 = zeros(d1,d1);
        p2 = zeros(d1,d1);
        p3 = zeros(d1,d1);
        p4 = zeros(d1,d1);
        if i == j % 对角矩阵
            p1 = eye(d1); p4 = p1;
            for k=1:d1
                if Z2(2,k) ~= 0
                    p2(Z2(1,k),Z2(2,k)) = 1;
                end
            end
            p3 = p2';
        elseif i<j % 上三角形
            for k=1:d1
                if Z2(2,k) ~= 0 && Z1(1,k) == Z2(1,k) && Z1(2,k) == Z2(2,k)
                    p2(Z2(1,k),Z2(2,k)) = 1;
                end
            end
            p3 = p2';
        end
        p = [p1 p2;p3 p4];
        P = [P,p];
    end
    T = [T;P];
end
% 对称化
T = T + T' - eye(size(T,1));
end