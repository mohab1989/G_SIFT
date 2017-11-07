close all
clear
clc
%imagesPath = '.\TestImages\';
imagesPath = 'D:\Images\hardMatches\Fusion_AMF\';
imagesNames = dir(strcat(imagesPath,'*.jpg'));
for imageId = 1 : length(imagesNames);
    imageName = strcat(imagesPath,imagesNames(imageId).name);
    vectorOfImages{imageId}=imread(imageName);
    image = rgb2gray( vectorOfImages{imageId});
    macFile = strcat( strtok(imagesNames(imageId).name, '.'),'.Mac');
    keypoints= zeros(4,1);
    descriptors = zeros(128,1);
    [height,width] = size(image);
    
    if exist(macFile)
        fileID = fopen(macFile,'r');
        lineSize = [1 2];
        tline = fscanf(fileID,'%d',lineSize);
        numberOfKeypoints= tline(1);
        for keypointId =1:numberOfKeypoints
            lineSize = [1 4];
            keypoints(:,keypointId)= fscanf(fileID,'%f ',lineSize);
            lineSize = [1 128];
            descriptors(:,keypointId)=fscanf(fileID,'%d ',lineSize);
        end
        fclose(fileID);
    else
        %% get sift features
        [keypoints,descriptors]= vl_sift(im2single(image));
        %% write SIFT features descriptors
        fileID = fopen(macFile,'w');
        fprintf(fileID,'%d 128\n',size(keypoints,2));
        for keypointId= 1:size(keypoints,2)
             keypoints(4,keypointId) = keypoints(4,keypointId)-(pi/2);
            if keypoints(4,keypointId) < 0
                keypoints(4,keypointId) = keypoints(4,keypointId)+(2*pi);
            end
            temp= keypoints(1,keypointId);
            keypoints(1,keypointId)= keypoints(2,keypointId);
            keypoints(2,keypointId)= temp;
            %keypoints(4,keypointId)=keypoints(4,keypointId)-(pi/2);
            fprintf(fileID,'%f ',keypoints(:,keypointId));
            fprintf(fileID,'\n');
            for line = 1:6
                fprintf(fileID,'%d ',descriptors(((line-1)*20)+1 : line*20,keypointId));
                fprintf(fileID,'\n');
            end
            fprintf(fileID,'%d ',descriptors(120:128 ,keypointId));
            fprintf(fileID,'\n');
%             fprintf(fileID,'%f ',descriptors(:,keypointId));
%             fprintf(fileID,'\n');
        end
        fclose(fileID);
    end    
    continue;
      vectorOfkeypoints{imageId}=keypoints;
      vectorOfDescriptors{imageId}=descriptors;
%     %% Wavelet Reduction
%     [decomposition ,bookKeeping ]=wavedec2(curvatureImage,2,'haar');
%     secondLevelApproximation = appcoef2(decomposition,bookKeeping,'haar',2);
%     imshow(imcomplement(secondLevelApproximation));

    GCmacFile= strcat('GC',macFile);
    globalContexts = zeros(5*(size(keypoints,2)),12);
    if exist(GCmacFile)
        fileID = fopen(GCmacFile,'r');
        lineSize = [1 2];
        tline = fscanf(fileID,'%d',lineSize);
        numberOfKeypoints= tline(1);
        for keypointId =1:5*numberOfKeypoints
            lineSize = [1 12];
            globalContexts(keypointId,:)= fscanf(fileID,'%f ',lineSize);
        end
        fclose(fileID);
    else
        %% calculate curvature image
        imshow(image);
       % VisualizeRandom50(keypoints,descriptors)
       % VisualizeKeyPoints(keypoints,descriptors);
        %image = imgaussfilt(image,2);
        windowSize=11;
        sigma=2;
        withRespectTo = ['x' 'x'];
        kernel = GaussianDerivative(windowSize,sigma,withRespectTo);
        surf(kernel);
        gxx = conv2(image,kernel,'same');
        withRespectTo = ['y' 'y'];
        kernel = GaussianDerivative(windowSize,sigma,withRespectTo);
        surf(kernel);
        gyy = conv2(image,kernel,'same');
        withRespectTo = ['x' 'y'];
        kernel = GaussianDerivative(windowSize,sigma,withRespectTo);
        surf(kernel);
        gxy = conv2(image,kernel,'same');
        imshow(gxx);
        imshow(gyy);
        imshow(gxy);
        curvatureImage = zeros(height,width);
        for y = 1 :  width
            for x = 1 : height
               Hessian = [gxx(x,y) gxy(x,y); gxy(x,y) gyy(x,y)];
               value = eig( Hessian );
               curvatureImage(x,y) = max(value);
               %curvatureImage(x,y) = 0.5*((Hessian(1,1)+Hessian(2,2)+sqrt((4*Hessian(1,2)*Hessian(2,1))+((Hessian(1,1)-Hessian(2,2))^2))));
               
            end
        end
        imshow(curvatureImage);
        imshow(imcomplement(curvatureImage));
        %% Calculate global Context
        %globalContexts = getGlobalContexts(curvatureImage,keypoints);
        globalContexts = efficientGetGlobalContexts(curvatureImage,keypoints);
        %% write features descriptors
        fileID = fopen(GCmacFile,'w');
        fprintf(fileID,'%d 60\n',size(keypoints,2));
        for keypointId = 1:(5*size(keypoints,2));
            fprintf(fileID,'%f ',globalContexts(keypointId,:));
            fprintf(fileID,'\n');
        end
        fclose(fileID);
    end
    vectorOfGlobalContexts{imageId}=globalContexts;
end


if size(imagesNames) <= 1
return;
end

% matches= zeros(2,1);
% distances = zeros(1,1);

%[matches, distances] =vl_ubcmatch(vectorOfDescriptors{1},vectorOfDescriptors{2},1.25);
ratio = 0.67;
distanceThreshold=0.4;
%weight=0.6;
weight=1;
[matches,distances] = match(vectorOfDescriptors{1},vectorOfDescriptors{2},vectorOfGlobalContexts{1},vectorOfGlobalContexts{2},ratio,distanceThreshold,weight);

fileID = fopen('matcheslist.txt','w');
fprintf(fileID,'0 1\n');
fprintf(fileID,'%d\n',size(matches,2));
for matchId= 1:size(matches,2);    
     fprintf(fileID,'%d %d\n',matches(1,matchId),matches(2,matchId));
end
 fclose(fileID);

% Mdl = KDTreeSearcher(vectorOfDescriptors{1}','Distance','euclidean','BucketSize',16);
% [Idx,D]=knnsearch(Mdl,vectorOfDescriptors{2}','K',2,'IncludeTies',false,'Distance','euclidean');
% counter=1;
% for matchesID = 1 : size(Idx,1)
%     if  D(matchesID,1) < ratio * D(matchesID,2)
%         matches(2,counter) = matchesID;
%         matches(1,counter)=Idx(matchesID,1);
%         distances(counter,1) = D(matchesID,1);
%         counter= counter+1;
%     end
% end
% [drop, perm] = sort(distances, 'descend') ;
% matches = matches(:, perm) ;
% distances  = distances(perm) ;
clusterCount =10;
numberOfClusters =ceil(size(matches,2)/clusterCount);
% for clusterID = 1 : numberOfClusters
figure(2) ; clf ;
imagesc(cat(2, vectorOfImages{1}, vectorOfImages{2})) ;

%range = (((clusterID-1) * (clusterCount-1))+1 : (clusterID) * clusterCount);
range =1: size(matches,2);
shift =size(vectorOfImages{1},2);
% if clusterID > 1
%     shift=0;
% end
% if ((clusterID) * clusterCount)> size(matches,2)
%     range = ((clusterID-1) * (clusterCount-1))+1 : size(matches,2);
% end
xa = vectorOfkeypoints{1}(1,matches(1,range)) ;
xb = vectorOfkeypoints{2}(1,matches(2,range)) +shift;
ya = vectorOfkeypoints{1}(2,matches(1,range)) ;
yb = vectorOfkeypoints{2}(2,matches(2,range)) ;

hold on ;
h = line([xa ; xb], [ya ; yb]) ;
%set(h,'linewidth', 1, 'color', 'b') ;

vl_plotframe(vectorOfkeypoints{1}(:,matches(1,range))) ;
vectorOfkeypoints{2}(1,:) = vectorOfkeypoints{2}(1,:) + shift ;
vl_plotframe(vectorOfkeypoints{2}(:,matches(2,range))) ;
axis image off ;
%end
fclose all;