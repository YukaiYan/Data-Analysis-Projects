% main classifier for three given digits
function [correct_rate] = threeDigitsClassifier(digit1_wave,digit2_wave,digit3_wave,Test_wave1,Test_wave2,Test_wave3,feature)

[U,~,~,threshold1,threshold2,w] = trainer(digit1_wave, digit2_wave, digit3_wave, feature);

if (threshold1 == -1 && threshold2 == -1)
    fprintf("Error: cannot order variables (threeDigitsClassifier)\n");
    correct_rate = 0;
    return
end

Test_Mat1 = U'* Test_wave1;          % PCA Projection
Test_Mat2 = U'* Test_wave2;
Test_Mat3 = U'* Test_wave3;

pVal1 = w' * Test_Mat1;
pVal2 = w' * Test_Mat2;
pVal3 = w' * Test_Mat3;

ResVec1 = (pVal1 < threshold1);                        % is digit 1
ResVec2 = (pVal2 > threshold1 & pVal2 < threshold2);   % is digit 2
ResVec3 = (pVal3 > threshold2);                        % is digit 3

% calculate stats
total_cases = size(Test_wave1,2) + size(Test_wave2,2) + size(Test_wave3,2);
correct_cases = sum(ResVec1(:)) + sum(ResVec2(:)) + sum(ResVec3(:));
correct_rate = correct_cases/total_cases;

end

function [U,S,V,threshold1, threshold2,w] = trainer(d1_wave,d2_wave,d3_wave,feature)

    nd1 = size(d1_wave,2);
    nd2 = size(d2_wave,2);
    nd3 = size(d3_wave,2);
    
    [U,S,V] = svd([d1_wave,d2_wave,d3_wave],'econ');
    digits = S*V';
    U = U(:,1:feature); % Add this in
    
    d1 = digits(1:feature,1:nd1);
    d2 = digits(1:feature,nd1+1:nd1+nd2);
    d3 = digits(1:feature,nd1+nd2+1:nd1+nd2+nd3);
    d = digits(1:feature,1:nd1+nd2+nd3);
    
    md1 = mean(d1,2);
    md2 = mean(d2,2);
    md3 = mean(d3,2);
    md = mean(d,2);

    Sw = 0;
    for k=1:nd1
        Sw = Sw + (d1(:,k)-md1)*(d1(:,k)-md1)';
    end
    for k=1:nd2
        Sw = Sw + (d2(:,k)-md2)*(d2(:,k)-md2)';
    end
    for k=1:nd3
        Sw = Sw + (d3(:,k)-md3)*(d3(:,k)-md3)';
    end
    
    %Sb = (md1-md2)*(md1-md2)';
    Sb = (md1-md)*(md1-md)';
    Sb = Sb + (md2-md)*(md2-md)';
    Sb = Sb + (md3-md)*(md3-md)';
    
    [V2,D] = eig(Sb,Sw);            % linear discriminant analysis
    [~,ind] = max(abs(diag(D)));
    w = V2(:,ind);
    w = w/norm(w,2);
    vd1 = w' * d1;
    vd2 = w' * d2;
    vd3 = w' * d3;

    % adjust the order to be vd1 < vd2 < vd3
    if mean(vd1) > mean(vd2)
        % vd1 > vd2 > vd3
        if mean(vd2) > mean(vd3)
            w = -w;
            vd1 = -vd1;
            vd2 = -vd2;
            vd3 = -vd3;
        end
        
        % TODO: implement more
    end
    
    if (mean(vd1) < mean(vd2) && mean(vd2) < mean(vd3))
        sortd1 = sort(vd1);
        sortd2 = sort(vd2);
        sortd3 = sort(vd3);
        
        t1 = length(sortd1);
        t2 = 1;
        while sortd1(t1) > sortd2(t2)
            t1 = t1 - 1;
            t2 = t2 + 1;
        end
        threshold1 = (sortd1(t1) + sortd2(t2))/2;
        
        t2 = length(sortd2);
        t3 = 1;
        while sortd2(t2) > sortd3(t3)
            t2 = t2 - 1;
            t3 = t3 + 1;
        end
        threshold2 = (sortd2(t2) + sortd3(t3))/2;
        return;
    else
        % for debugging
        threshold1 = -1;
        threshold2 = -1;
        
        fprintf("Please order the variables(either order is fine).\n");
        fprintf("Current mean: %f, %f, %f.\n",mean(vd1),mean(vd2),mean(vd3))
    end

end
