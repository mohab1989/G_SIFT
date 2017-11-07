function globalContexts = getGlobalContexts(curvatureImage,keypoints)
curvatureImage= imgaussfilt(curvatureImage,3);
globalContexts = zeros(size(keypoints,2) * 5,12);
for keypointId = 1:size(keypoints,2)
    keypointX =keypoints(1,keypointId);
    keypointY =keypoints(2,keypointId);
    keypointSize =keypoints(3,keypointId);
    keypointOrientation =keypoints(4,keypointId);
    if keypointOrientation < 0
        keypointOrientation = keypointOrientation+(2*pi);
    end
    keypointOrientationInDegrees = keypointOrientation *(180/pi);
    [curvatureImageHeight,curvatureImageWidth] = size(curvatureImage);
    shapeContextRadius = int32(sqrt((curvatureImageWidth^2)+(curvatureImageHeight^2))/2);
    startX = keypointX - shapeContextRadius;
    endX = keypointX + shapeContextRadius;
    startY = keypointY - shapeContextRadius;
    endY = keypointY + shapeContextRadius;
    if(startX < 1)
        startX=1;
    end
    if(startY < 1)
        startY=1;
    end
    
    if(endX > curvatureImageWidth)
        endX=curvatureImageWidth;
    end
    if(endY > curvatureImageHeight)
        endY=curvatureImageHeight;
    end
    sigma = keypointSize;
    weightedCurvatureImage =  zeros(endY-startY,endX-startX);
    weights = zeros(endY-startY,endX-startX);
    globalContext = zeros(5,12);
    
    for x = startX : endX
        for y = startY : endY
            weight = 1 - exp(-(((double(x)-keypointX)^2)+((double(y)-keypointY)^2))/double((2 * (sigma^2))));
            weights(y,x)=weight;
            weightedCurvatureImage(y,x)= weight*curvatureImage(y,x); 
            if x==keypointX && y ==keypointY
                continue;
            end
            slope =((double(y)-keypointY)/(double(x)-keypointX));
            angle =0;
            if y < keypointY
                if x < keypointX
                    angle=(pi/2)+atan(slope);
                else
                    angle= ((3/2)*pi) + atan(slope);
                end
            else
                if x < keypointX
                     angle= (pi/2) + atan(slope);
                else
                    angle=((3/2)*pi) + atan(slope);
                end
            end
            difference =(angle -keypointOrientation);
            if difference < 0
                difference = difference+(2*pi);
            end
            angularDistance = ((6/pi)*difference);
            distance =norm([(double(x)-keypointX) (double(y)-keypointY)]);
            if distance >= shapeContextRadius
                continue;
            end
            radialDistance = max(1,floor(log2(distance/double(shapeContextRadius))+6));
            angularDistance = ceil(angularDistance);                    
            globalContext(radialDistance,angularDistance) =globalContext(radialDistance,angularDistance)+ weightedCurvatureImage(y,x);
%             skip  = false;
%             for l = 1:size(test,1);
%                 if test(l,1)==angularDistance;
%                     if test(l,2)==radialDistance;
%                         test(l,3)=1 - exp(double(-(((x-keypointX)^2)+((y-keypointY)^2))/(2 * (sigma^2))));                                             
%                         skip = true;
%                         continue;
%                     end
%                 end
%             end
%             if(~skip)
%                 test(size(test,1)+1,1)=angularDistance;
%                 test(size(test,1),2)=radialDistance;
%                 test(size(test,1),3) =1 - exp(double(-(((x-keypointX)^2)+((y-keypointY)^2))/(2 * (sigma^2))));
%             end

        end
    end
    globalContextNorm = norm(globalContext(:));
    globalContexts(((keypointId-1)*5)+1 : keypointId*5,:) = globalContext/globalContextNorm;
end
end