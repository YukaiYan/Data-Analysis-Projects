% Classify digits and perform wavelet transformation
function [digit0,digit1,digit2,digit3,digit4,digit5,digit6,digit7,digit8,digit9] = sortDigits(images, labels)

Digit0 = []; count0 = 1;
Digit1 = []; count1 = 1;
Digit2 = []; count2 = 1;
Digit3 = []; count3 = 1;
Digit4 = []; count4 = 1;
Digit5 = []; count5 = 1;
Digit6 = []; count6 = 1;
Digit7 = []; count7 = 1;
Digit8 = []; count8 = 1;
Digit9 = []; count9 = 1;
for i = 1:size(images,3)
    if labels(i) == 0
        Digit0(:,:,count0) = images(:,:,i);
        count0 = count0 + 1;
    elseif labels(i) == 1
        Digit1(:,:,count1) = images(:,:,i);
        count1 = count1 + 1;
    elseif labels(i) == 2
        Digit2(:,:,count2) = images(:,:,i);
        count2 = count2 + 1;
    elseif labels(i) == 3
        Digit3(:,:,count3) = images(:,:,i);
        count3 = count3 + 1;
    elseif labels(i) == 4
        Digit4(:,:,count4) = images(:,:,i);
        count4 = count4 + 1;
    elseif labels(i) == 5
        Digit5(:,:,count5) = images(:,:,i);
        count5 = count5 + 1;
    elseif labels(i) == 6
        Digit6(:,:,count6) = images(:,:,i);
        count6 = count6 + 1;
    elseif labels(i) == 7
        Digit7(:,:,count7) = images(:,:,i);
        count7 = count7 + 1;
    elseif labels(i) == 8
        Digit8(:,:,count8) = images(:,:,i);
        count8 = count8 + 1;
    elseif labels(i) == 9
        Digit9(:,:,count9) = images(:,:,i);
        count9 = count9 + 1;
    end
end

digit0 = d_wavelet(Digit0);
digit1 = d_wavelet(Digit1);
digit2 = d_wavelet(Digit2);
digit3 = d_wavelet(Digit3);
digit4 = d_wavelet(Digit4);
digit5 = d_wavelet(Digit5);
digit6 = d_wavelet(Digit6);
digit7 = d_wavelet(Digit7);
digit8 = d_wavelet(Digit8);
digit9 = d_wavelet(Digit9);

end





