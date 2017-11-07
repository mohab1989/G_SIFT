function VisualizeKeyPoints(keypoints,descriptors)
sel = [1 2];
h1 = vl_plotframe(keypoints(:,sel)) ;
h2 = vl_plotframe(keypoints(:,sel)) ;
h3 = vl_plotsiftdescriptor(descriptors(:,sel),keypoints(:,sel)) ;
set(h1,'color','k','linewidth',3) ;
set(h2,'color','y','linewidth',2) ;
set(h3,'color','g') ;
end