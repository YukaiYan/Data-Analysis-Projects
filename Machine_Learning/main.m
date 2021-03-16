%% clean and load data
clear variables; close all; clc;

% load data
[train_images, train_labels] = mnist_parse("train-images.idx3-ubyte", "train-labels.idx1-ubyte", false);
[test_images, test_labels] = mnist_parse("t10k-images.idx3-ubyte", "t10k-labels.idx1-ubyte", false);

% transform the entire dataset
train_wavelet = d_wavelet(train_images);
test_wavelet = d_wavelet(test_images);

% classify data by their labels
[Digit0,Digit1,Digit2,Digit3,Digit4,Digit5,Digit6,Digit7,Digit8,Digit9] = sortDigits(train_images, train_labels);
[Test0,Test1,Test2,Test3,Test4,Test5,Test6,Test7,Test8,Test9] = sortDigits(test_images, test_labels);

% cutoff for adjusting features
cutoff = 0.80;

% default feature
feature = 25;

% Example: display a few data in the training set
image_size = size(train_images, 1);
figure(1)
image_index = 0;
while image_index < 10
   for i = 1:size(test_labels)
      if (train_labels(i) == image_index)
         subplot(1,10,image_index + 1);
         imshow(train_images(:,:,i));
         title(num2str(image_index));
         break;
      end
   end
   image_index = image_index + 1;
end


%% Perform wavelet transformation and Singular Value Decomposition
digit_wave = zeros(size(train_images,1)*size(train_images,2)/4,size(train_images,3));
for i = 1:size(train_images,3)
    digit_wave(:,i) = d_wavelet(train_images(:,:,i));
end
[U,S,V] = svd(digit_wave,'econ');

sig = diag(S);
cumulative_energy = cumsum(sig.^2)/sum(sig.^2);
for i = 1:length(cumulative_energy)
    if cumulative_energy(i) >= cutoff
        break
    end
end
feature = i;

%% Perform analysis 
% plot the first nine principal components
figure(2)
for k = 1:9
    subplot(3,3,k)
    ut1 = reshape(U(:,k),14,14);
    ut2 = rescale(ut1);
    imshow(ut2);
end


% plot singular values
figure(3)
subplot(1,3,1); plot(sig,'ko','Linewidth',2);
ylabel('\sigma');xlabel('singular values')
subplot(1,3,2); semilogy(sig,'ko','Linewidth',2);
ylabel('\sigma');xlabel('singular values')
subplot(1,3,3);plot(cumulative_energy,'ko','Linewidth',2)
ylabel('Cumulative Energy');xlabel('singular values');


% Project selected V-modes
% for k = 1:3
%     subplot(3,1,k);
%     plot(t,V(t,k), 'ko-');
%     legend(['Mode ', num2str(k)], 'Location','SouthEast');
% end
figure(4)
C = {'m','k','b',[.5 .8 .7],'r','g','c','y',[.5 .6 .7],[.8 .2 .6]}; % Cell array of colors.
legends = cell(10,1);
for label = 0:9
    indices = find(train_labels == label);
    plot3(V(indices,2), V(indices,3),V(indices,5), '.','color',C{label+1});
    legends{label+1} = num2str(label);
    hold on, drawnow;
end
xlabel('2nd V-mode');
ylabel('3rd V-mode');
zlabel('5rd V-mode');
legend(legends);



%% Find two digits that are most easy/difficult to separate
minRate = 1; minDigits = zeros(1,2);
maxRate = 0; maxDigits = zeros(1,2);
figure(5)
for i = 0:9
    correct_rates = zeros(10,1);
    for j = 0:9
        if (i == j)
            correct_rates(j+1) = 1;
            continue
        end
        digit1 = ['Digit',num2str(i)];
        digit2 = ['Digit',num2str(j)];
        test1 = ['Test',num2str(i)];
        test2 = ['Test',num2str(j)];
        
        correct_rate = twoDigitsClassifier(eval(digit1),eval(digit2),eval(test1),eval(test2),feature);
        correct_rates(j+1) = correct_rate;
        if (correct_rate < minRate)
            minRate = correct_rate;
            minDigits(1) = i;
            minDigits(2) = j;
        end
        if (correct_rate > maxRate)
            maxRate = correct_rate;
            maxDigits(1) = i;
            maxDigits(2) = j;
        end
    end
    
    plot(0:9,correct_rates, '-o','color',C{i+1});
    xlabel('digit 2'), ylabel('Success Rate')
    xlim([0,9]),ylim([0.85,1.0])
    legends{i+1} = ['digit1 = ', num2str(i)];
    title(legends{i+1});
    hold on, grid on, drawnow
end
title('Success Rate classifying 2 digits');
legend(legends,'Location','SouthEast');



%% Try classify three digits
% may not work on certain orders, see output in the console to debug.
clc;

% an example of 'buggy' code
% threeDigitsClassifier(Digit1,Digit3,Digit5,Test1,Test3,Test5);

% fix the order
% threeDigitsClassifier(Digit1,Digit5,Digit3,Test1,Test5,Test3);
rate1 = threeDigitsClassifier(Digit3,Digit5,Digit1,Test3,Test5,Test1,feature); % 1,3,5
rate2 = threeDigitsClassifier(Digit9,Digit4,Digit1,Test9,Test4,Test1,feature); % 1,4,9
rate3 = threeDigitsClassifier(Digit0,Digit2,Digit1,Test0,Test2,Test1,feature); % 0,1,2


%% Other Machine Learning Methods
clc; close all;

% classification tree
% figure(6)
for numSplits = 1:50
    tree=fitctree(train_wavelet',train_labels,'MaxNumSplits',numSplits,'CrossVal','on');
    % view(tree.Trained{1},'Mode','graph');
    % fprintf(['done ' , num2str(numSplits), '\n']);
    classError = kfoldLoss(tree);
    plot(numSplits, classError,'-o');
    hold on, drawnow;
end
xlabel('Max number of splits');
ylabel('cross-validated classification error.');
tree=fitctree(train_wavelet',train_labels,'MaxNumSplits',10,'CrossVal','on');
view(tree.Trained{1},'Mode','graph');


% SVM classifier with training data, labels and test set
Mdl = fitcecoc(train_wavelet',train_labels);
predict_labels = Mdl.predict(test_wavelet');
SVMError = length(find(predict_labels - test_labels == 0))/length(test_labels)



