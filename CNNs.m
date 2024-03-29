% conversion to gray-scale B
image_folder = 'C:\Users\User\Desktop\uni\II semester\DSP\specs\B'; 

filenames = dir(fullfile(image_folder, '*.png'))  
 total_images = numel(filenames)   
 for n = 1:total_images
  f= fullfile(image_folder, filenames(n).name)        
our_images = imread(f)     
grey=rgb2gray(our_images)
  imshow(grey)
 baseFileName = sprintf('Image # %d.png', n);
 fullFileName = fullfile('C:\Users\User\Desktop\uni\II semester\DSP\specs1\grayB', baseFileName);
saveas(gcf, fullFileName);
end
   % conversion to gray-scale A
image_folder = 'C:\Users\User\Desktop\uni\II semester\DSP\specs\A'; 

filenames = dir(fullfile(image_folder, '*.png'))  
 total_images = numel(filenames)   
 for n = 1:total_images
  f= fullfile(image_folder, filenames(n).name)        
our_images = imread(f)     
grey=rgb2gray(our_images)
  imshow(grey)
 baseFileName = sprintf('Image # %d.png', n);
 fullFileName = fullfile('C:\Users\User\Desktop\uni\II semester\DSP\specs1\grayA', baseFileName);
saveas(gcf, fullFileName);
end
% CNN
Image = imageDatastore('specs1','IncludeSubfolders',true,'LabelSource','foldernames');
Image.ReadFcn = @(loc)rgb2gray(imresize(imread(loc),[28,28])); % is this necessary
Image=shuffle(Image);

layers = [
    imageInputLayer([28 28 1])

    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(2,'Stride',2)

    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(2,'Stride',2)
  
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    dropoutLayer(0.5)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

%5 folds cross validation
ii = 5; % number of folds

partStores{ii} = [];
for i = 1:ii
   temp = partition(Image, ii, i);
   partStores{i} = temp.Files;
end


% this will give us some randomization
% though it is still advisable to randomize the data before hand
idx = crossvalind('Kfold', ii, ii);
for i = 1:1
    test_idx = (idx == i);
    train_idx = ~test_idx;

    imageVal = imageDatastore(partStores{test_idx}, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
    imageVal.ReadFcn = @(loc)rgb2gray(imresize(imread(loc),[28,28]));
    imageTrain = imageDatastore(cat(1, partStores{train_idx}), 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
    imageTrain.ReadFcn = @(loc)rgb2gray(imresize(imread(loc),[28,28]));
    % do your training and predictions here, maybe pre-allocate them before the loop, too
    %net{i} = trainNetwork(train_Store, layers options);
    %pred{i} = classify(net, test_Store);
    miniBatchSize  = 128;
    validationFrequency = floor(numel(Image.Labels)/miniBatchSize);
    options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',40, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',3, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imageVal, ...
    'Plots','training-progress', ...
    'Verbose',false);

net = trainNetwork(imageTrain,layers,options);

YPred = classify(net,imageVal);
YValidation = imageVal.Labels;

accuracy(i) = sum(YPred == YValidation)/numel(YValidation)*100
output = 2*ones(size(YPred));
output(YPred == 'epiliptic') = 1;
output = dummyvar(output);
Target = 2*ones(size(YValidation));
Target(YValidation == 'epiliptic') = 1;
Target = dummyvar(Target);


[~,cm,~,per] = confusion(Target',output');
TP = cm(1,1);
FP = cm(1,2);
FN = cm(2,1);
TN = cm(2,2);
Sensitivity(i) = TP/(TP + FN)*100; % TPR (true positives)/(all output positives)
Specificity(i) = TN/(TN + FP)*100; % TNR (true negatives)/(all output negatives)
Sensitivity(i) = per(1,3);
Specificity(i) = per(1,4);

end
averageAccuracy=sum(accuracy)/ii

