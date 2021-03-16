% main classifier for two given digits
function [correct_rate] = twoDigitsClassifier(digit1_wave,digit2_wave,Test_wave1,Test_wave2,feature)

[U,~,~,threshold,w,~,~] = trainer(digit1_wave, digit2_wave,feature);

Test_Mat1 = U'* Test_wave1;     % PCA Projection
Test_Mat2 = U'* Test_wave2;
pVal1 = w' * Test_Mat1;
pVal2 = w' * Test_Mat2;

ResVec1 = (pVal1 < threshold);  % is digit 1
ResVec2 = (pVal2 > threshold);  % is digit 2

% calculate stats
total_cases = size(Test_wave1,2) + size(Test_wave2,2);
correct_cases = sum(ResVec1(:)) + sum(ResVec2(:));
correct_rate = correct_cases/total_cases;

end

% train data
function [U,S,V,threshold,w,sortd1,sortd2] = trainer(d1_wave,d2_wave,feature)

    nd1 = size(d1_wave,2);
    nd2 = size(d2_wave,2);
    [U,S,V] = svd([d1_wave d2_wave],'econ');
    digits = S*V';
    U = U(:,1:feature); % Add this in
    d1 = digits(1:feature,1:nd1);
    d2 = digits(1:feature,nd1+1:nd1+nd2);
    md1 = mean(d1,2);
    md2 = mean(d2,2);

    Sw = 0;
    for k=1:nd1
        Sw = Sw + (d1(:,k)-md1)*(d1(:,k)-md1)';
    end
    for k=1:nd2
        Sw = Sw + (d2(:,k)-md2)*(d2(:,k)-md2)';
    end
    Sb = (md1-md2)*(md1-md2)';

    [V2,D] = eig(Sb,Sw);        % linear discriminant analysis
    [~,ind] = max(abs(diag(D)));
    w = V2(:,ind);
    w = w/norm(w,2);
    vd1 = w' * d1;
    vd2 = w' * d2;

    % adjust the order to be vd1 < vd2
    if mean(vd1) > mean(vd2)
        w = -w;
        vd1 = -vd1;
        vd2 = -vd2;
    end
    
    sortd1 = sort(vd1);
    sortd2 = sort(vd2);
    t1 = length(sortd1);
    t2 = 1;
    while sortd1(t1) > sortd2(t2)
        t1 = t1 - 1;
        t2 = t2 + 1;
    end
    threshold = (sortd1(t1) + sortd2(t2))/2;

end
