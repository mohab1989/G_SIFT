function [matches,distances] = match(descriptors1,descriptors2,globalContexts1,globalContexts2,ratio,threshold,weight)
    numberOfKeypoints1 = size(descriptors1,2);
    numberOfKeypoints2 = size(descriptors2,2);   
    distances=zeros(1,1);
    matches=zeros(2,1);
    counter=1;
    for kp1 = 1 : numberOfKeypoints1
        bestMatches = Inf * ones(2,3);
        normDescriptors1= norm(double(descriptors1(:,kp1)));
        normDescriptors1=descriptors1(:,kp1)/normDescriptors1;
        
        vectorizedGlobalContext1 =  globalContexts1(((kp1-1)*5)+1 : kp1*5,:);
        vectorizedGlobalContext1=vectorizedGlobalContext1(:);
        for kp2 = 1 : numberOfKeypoints2
            normDescriptors2=norm(double(descriptors2(:,kp2)));
            normDescriptors2=descriptors2(:,kp2)/normDescriptors2;
            
            vectorizedGlobalContext2 =  globalContexts2(((kp2-1)*5)+1 : kp2*5,:);
            vectorizedGlobalContext2 = vectorizedGlobalContext2(:);
            %% calculate SIFT distance 
            siftDistance = sqrt(sum((normDescriptors1-normDescriptors2).^2));            
            %% calculate global context distance
            globalContextDistance = 0.5*sum(((vectorizedGlobalContext1-vectorizedGlobalContext2).^2)./abs(vectorizedGlobalContext1+vectorizedGlobalContext2+eps));            
            %% combined Distance
            combinedDistance = (weight*siftDistance)+((1-weight)*globalContextDistance);
            if combinedDistance < threshold
                if combinedDistance < bestMatches(1,3)
                    bestMatches(1,1) = kp1;
                    bestMatches(1,2) = kp2;
                    bestMatches(1,3) = combinedDistance;
                else
                    if combinedDistance < bestMatches(2,3)
                        bestMatches(2,1) = kp1;
                        bestMatches(2,2) = kp2;
                        bestMatches(2,3) = combinedDistance;
                    end
                end
            end
        end
        if bestMatches(1,3) < ratio * bestMatches(2,3)
            matches(1,counter)=bestMatches(1,1);
            matches(2,counter)=bestMatches(1,2);
            distances(counter,1)=bestMatches(1,3);
            deletedMatchesIndicies = zeros(1,1);
            deletedMatchesCOunter =1;
            for  matchesId= 1:(size(matches,2)-1)
                if matches(2,counter) == matches(2,matchesId)
                    if distances(counter,1) < distances(matchesId,1)
                        deletedMatchesIndicies(deletedMatchesCOunter)= matchesId;
%                         matches(:,matchesId) = [];
%                         distances(matchesId,:) =[];
                    else
                        deletedMatchesIndicies(deletedMatchesCOunter)=counter;
%                         matches(:,counter) = [];
%                         distances(counter,:) =[];
                    end
                    deletedMatchesCOunter= deletedMatchesCOunter+1;
                end
            end
            for matchDuplicateId = 1: size(deletedMatchesIndicies)
                deletedId = deletedMatchesIndicies(matchDuplicateId);
                if deletedId == 0
                    continue;
                end
                matches(:,deletedId) = [];
                distances(deletedId,:) =[];
                counter = counter-1;
            end
            counter = counter +1;
        end
    end
end