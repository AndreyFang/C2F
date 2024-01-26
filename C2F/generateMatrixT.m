function T = generateMatrixT(matchlist)

descs = size(matchlist,3);
d1 = size(matchlist,1); 
d2 = size(matchlist,2);
T = [];
for i = 1:descs
    P = []; 
    Z1 = matchlist(:,:,i); 
    for j=1:descs
        Z2 = matchlist(:,:,j); 
        
        if i == j 
            p1 = Z1*Z1';
            p4 = Z1'*Z1;
            p2 = Z1;
            p3 = p2';
        elseif i<j 
            p1 = zeros(d1,1);
            p4 = zeros(d2,1);
            
            k1 = Z1*Z1'; k2 = Z2*Z2';
            k1 = diag(k1); k2 = diag(k2);
            [m,~] = find(k1 == 1); [n,~] = find(k2 == 1);
            m = intersect(m,n);
            p1(m) = 1;
            p1 = diag(p1);
            p2 = Z1.*Z2;
            p3 = p2';
            
            k1 = Z1'*Z1; k2 = Z2'*Z2;
            k1 = diag(k1); k2 = diag(k2);
            [m,~] = find(k1 == 1); [n,~] = find(k2 == 1);
            m = intersect(m,n);
            p4(m) = 1;
            p4 = diag(p4);
        else 
            p1 = zeros(d1);
            p4 = zeros(d2);
            p2 = zeros(d1,d2);
            p3 = p2';
        end
        p = [p1 p2;p3 p4];
        P = [P,p];
    end
    T = [T;P];
end

T = T + T' - eye(size(T,1));
end