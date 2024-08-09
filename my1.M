%function classify vehicle() 
clc;
    clear all;
    close all;

    %pold=pwd;
    %select and load the picture from file
    cd images
    [filename, pathname] = uigetfile('*.*', 'Click the image file you want to process', 'Pick an Image file');
%     cd=pathname;
    origImg = imread(filename);
    cd ..
    [h w band] = size(origImg);
    
    if(band ~= 3)
        h = msgbox('Only Color Image Supported','Image Error');
        finish;
    end;
    
    figure;
    imshow(origImg);
     
    title({'Original image'});
    
    im = double(origImg);
    
    % Convert from RGB color space to CIE color space
    X = im(:,:,1) .* 0.412453 + im(:,:,2) .* 0.35758 + im(:,:,3) .* 0.180423;
    Y = im(:,:,1) .* 0.212671 + im(:,:,2) .* 0.71516 + im(:,:,3) .* 0.072169;
    Z = im(:,:,1) .* 0.019334 + im(:,:,2) .* 0.119193 + im(:,:,3) .* 0.950227;
    
    %conditions for yellow color in CIE-XYZ space
    X1_YELLOW = 0.38;
    X2_YELLOW = 0.413;
    SUM1_YELLOW = 537;
    SUM2_YELLOW = 181;
    %SUM3_YELLOW = 500;
    MIN_Y_YELLOW = 0.44;
    MAX_Y_YELLOW = 0.4359;
    
    %normalize
    sum = X + Y + Z;
    x = X ./ (sum + 1);   % add 1 to avoid divide by 0
    y = Y ./ (sum + 1);
    
    
    
    % create a binary image by applying yellow color conditions
    % regions of image which satisfy criteria will be represented by white
    % rest of the areas will be black
    xImage = ( ((x > X1_YELLOW) & (sum > SUM1_YELLOW)) | ((x < X2_YELLOW) & (sum < SUM2_YELLOW)) );
    yImage = ((y > MIN_Y_YELLOW) & (sum > SUM1_YELLOW)) | ((y < MAX_Y_YELLOW) & (sum > SUM1_YELLOW));
    binImgYellow = xImage & yImage;
    
    figure;
    imshow(binImgYellow);
     
    title({'Yellow color regions of the image'});
        
    % dilate the image so as to fill holes, cracks etc. in license plate
    dilImgYellow = imdilate(binImgYellow, strel('disk', 7));
    
    % label connected components of the dilated image
    conImgYellow = bwlabel(dilImgYellow);
    featuresYellow = regionprops(conImgYellow);
    
    % License plate shape criteria
    LP_MIN_AREA = 5000;    % minimum area
    LP_MAX_RATIO = 0.50;    % minimum aspect ratio height:width
    LP_MIN_RATIO = 0.05;    % maximum aspect ratio
    
    % license plate is likely to be found in the lower half of the image
    % we will try to find out a yellow region which matches the license
    % plate shape criteria and is at the greatest depth
    
    depthYellow = -1; % assume license plate is at the top
    lpCandidates = [];
    for i = 1 : length([featuresYellow.Area])
        if (featuresYellow(i).BoundingBox(2) >= depthYellow && ... % if depth is greater than = previous
           featuresYellow(i).Area > LP_MIN_AREA && ...       % satisfies minimum area condition
           featuresYellow(i).BoundingBox(4)/featuresYellow(i).BoundingBox(3) <= LP_MAX_RATIO && ... % satisfies aspect ratio condition
           featuresYellow(i).BoundingBox(4)/featuresYellow(i).BoundingBox(3) >= LP_MIN_RATIO)
           depthYellow = featuresYellow(i).BoundingBox(2);
           lpCandidates = [lpCandidates featuresYellow(i).Area];
        end;
    end;
  
    if (length(lpCandidates) == 0)   % no regions at depthYellow, select region with maximum area
        indexY = (find([featuresYellow.Area] == max([featuresYellow.Area])));
    else
        indexY = (find([featuresYellow.Area] == max(lpCandidates)));  % select the one with maximum area
    end;
    
if (indexY ~= 0)
    lpAreaYellow = featuresYellow(indexY).Area;   % area of shortlisted LP region
    % crop the license plate area if possible
    [x11 x12 y11 y12] = trimLicensePlate(binImgYellow, conImgYellow, indexY, ...
                        featuresYellow(indexY).BoundingBox(1), featuresYellow(indexY).BoundingBox(2), ...
                        featuresYellow(indexY).BoundingBox(3), featuresYellow(indexY).BoundingBox(4));
        
else
        lpAreaYellow = 1;
        x11 = 1;
        x12 = 1;
        y11 = 1;
        y12 = 1;
end;
    %figure;
    %imshow(lpImageYellow);
    
    
    % now start testing for white license plate
    
    % conditions for white color
    SUM1_WHITE = 664;
    SUM2_WHITE = 775;
    xImage = (sum > SUM1_WHITE); %& (x > 0.31);% & (sum < SUM2_WHITE);
    yImage = (sum > SUM1_WHITE); %& (y > 0.32); %& (sum < SUM2_WHITE);
    
    binImgWhite = xImage & yImage;
    figure;
    imshow(binImgWhite);
     
    title({'White color regions of the image'});
    
    % label connected components of the image
    binImgWhiteTemp = imdilate(binImgWhite, strel('disk', 3));
    conImgWhite = bwlabel(binImgWhiteTemp);
    featuresWhite = regionprops(conImgWhite);
    
    depthWhite = -1; % assume license plate is at the top
    lpCandidates = [];
    for i = 1 : length([featuresWhite.Area])
        if (featuresWhite(i).BoundingBox(2) >= depthWhite && ... % if depth is gr eater than = previous
           featuresWhite(i).Area > LP_MIN_AREA && ...       % satisfies minimum area condition
           featuresWhite(i).BoundingBox(4)/featuresWhite(i).BoundingBox(3) <= LP_MAX_RATIO && ... % satisfies aspect ratio condition
           featuresWhite(i).BoundingBox(4)/featuresWhite(i).BoundingBox(3) >= LP_MIN_RATIO)
           depthWhite = featuresWhite(i).BoundingBox(2);
           lpCandidates = [lpCandidates featuresWhite(i).Area];
        end;
    end;
    
    
    if (length(lpCandidates) == 0)   % no regions at depthYellow, select region with maximum area
        indexW = (find([featuresWhite.Area] == max([featuresWhite.Area])));
    else
        indexW = (find([featuresWhite.Area] == max(lpCandidates)));  % select the one with maximum area
    end;
    
if (indexW ~= 0)
     lpAreaWhite = featuresWhite(indexW).Area;   % area of shortlisted LP region
    
    % crop the license plate area if possible
     [x1 x2 y1 y2] = trimLicensePlate(binImgWhite, conImgWhite, indexW, ...
                        featuresWhite(indexW).BoundingBox(1), featuresWhite(indexW).BoundingBox(2), ...
                        featuresWhite(indexW).BoundingBox(3), featuresWhite(indexW).BoundingBox(4));
        
    
    else
        lpAreaWhite = 1;
        x1 = 1;
        x2 = 1;
        y1 = 1;
        y2 = 1;
end;

   
    % now we need to identify the type of plate white or yellow
    % again assuming that license plate lies towards the bottom of the
    % image we try to identify whether it is white or yellow
    flag = 0;     % 1 - Yellow, 2 - White, 3 - Undecided
    if(depthYellow < 0)
        flag = 2;  % possibly it is white 
    elseif(depthWhite < 0)
        flag = 1;
    elseif(depthYellow > depthWhite)
        flag = 3;
    elseif(depthYellow < depthWhite)
        flag = 3;
    end;
    
    LP_MAX_AREA = 200000; %sanity check
    
   if(lpAreaYellow > LP_MIN_AREA && lpAreaYellow < LP_MAX_AREA)
        flag = 1;
    elseif(lpAreaWhite > LP_MIN_AREA && lpAreaWhite < LP_MAX_AREA )
        flag = 2;
        else flag=3;
   end;
   
    % display classified output
    if(flag == 1)
        lpImageYellow = origImg(x11:x12, y11:y12,:); 
        figure;
        imshow(lpImageYellow);
        
        h = msgbox('Commercial Vechicle','Image Classified');
       elseif(flag == 2)
        lpImageWhite = origImg(x1:x2,y1:y2 ,:);
        figure;
        imshow(lpImageWhite);
        h = msgbox('Private Vechicle','Image Classified');
    else
        figure;
        title({'Not an appropriate image for License Plate Processing'});
    end;
cd(pold);
return;


% this function trims a detected license plate by trying to identify the
% location of characters in the detected license plate
% binImage - binary image of the vehicle
% lblImage - labelled image (connected components)
% lpLabel - label of the license plate region in lblImage
% lpLeft, lpTop, lpWidth, lpHeight - bounding box of the license plate
% region
%function x1, x2, y1, y2 = trimLicensePlate(binImage, lblImage, lpLabel, lpLeft, lpTop, lpWidth, lpHeight)
 
   PADDING = 10;
   X_ZERO_CROSSINGS = 15;
   Y_ZERO_CROSSINGS = 4;
   
   %figure;
   %imshow(binImage);
   %lpLabel
   %lpTop
   %lpLeft
   %lpWidth
   %lpHeight
   
   y1 = ceil(lpLeft);
   y2 = y1 + lpWidth;
   x1 = ceil(lpTop);
   x2 = x1 + lpHeight;
   
   %x1
   %x2
   %y1
   %y2
   %figure;
   %imshow(binImage(x1:x2, y1:y2));
   
   % for all image pixels lying within the bounding box of license plate if
   % they don't belong to license plate region turn them black
   for i =  x1 : 1 : x2-1 
       for j = y1 : 1 : y2-1 
           if (lblImage(i, j) ~= lpLabel)
               binImage(i, j) = 0;
           end;
       end;
   end;
   
   %figure;
   %imshow(binImage);
   
   % now we try to find out number of zero crossings, i.e. black to white
   % and white to black transition in the bounding box
   xZeroCross = [];
   for i = x1 : 1 : x2-1
       xCount = 0;
       for j = y1 : 1 : y2 - 2
           if (binImage(i, j)  ~= binImage(i, j+1)) % there is a zero crossing
               xCount = xCount + 1;
           end;
       end;
       xZeroCross = [xZeroCross xCount];
   end;
   
   % license plate generally has 10 characters, we can expect atleast 2
   % zero crossings per character, therefore total number of zero crossings
   % in license plate region would be around 20, we select 15 as the 
   % criteria to discriminate between license plate and non license plate
   % regions
   
   % start cropping the bounding box from top, till you reach a row which
   % meets zero crossing criteria
   for i = 1 : 1 : lpHeight
       if (xZeroCross(i) < X_ZERO_CROSSINGS)
           x1 = x1 + 1;
       else
           break;
       end;
   end;
    
   % start cropping the bounding box from bottom, till you find a row which
   % meets zero crossing criteria
   for i = lpHeight : -1 : 1
       if (xZeroCross(i) < X_ZERO_CROSSINGS)
           x2 = x2 - 1;
       else
           break;
       end;
   end;
   
   % similarly finding y crossings, but it doesn't help since we have to
   % keep parameter very low (2) which doesn't eliminate other regions
   yZeroCross = [];
   for i = y1 : 1 : y2-1
       yCount = 0;
       for j = x1 : 1 : x2 - 2
           if (binImage(j, i)  ~= binImage(j+1, i)) % there is a zero crossing
               yCount = yCount + 1;
           end;
       end;
       yZeroCross = [yZeroCross yCount];
   end;
   
   for i = 1 : 1 : lpWidth
       if (yZeroCross(i) < Y_ZERO_CROSSINGS)
           y1 = y1 + 1;
       else
           break;
       end;
   end;
   
   for i = lpWidth : -1 : 1
       if (yZeroCross(i) < Y_ZERO_CROSSINGS)
           y2 = y2 - 1;
       else
           break;
       end;
   end;
   
   x1=x1 - PADDING;
   x2=x2 + PADDING;
   y1=y1 - PADDING;
   y2=y2 + PADDING;
   
   x1 = max(x1, 1);
   x2 = min(x2, size(binImage, 1));
   y1 = max((y1), 1);
   y2 = min((y2), size(binImage, 2));
   
   %xZeroCross
   %x1
   %x2
   %y1
   %y2
   
return;

