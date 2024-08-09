clc;
    clear all;
    close all;

    %pold=pwd;
    %select and load the picture from file
%      [filename, pathname] = uigetfile('*.*', 'Click the image file you want to process', 'Pick an Image file');
%      cd=pathname;
    origImg = imread('peppers.png');
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
    SUM1_YELLOW = 300;
    SUM2_YELLOW = 100;
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
     SUM1_WHITE = 500;
    SUM2_WHITE = 775;
    xImage = (sum > SUM1_WHITE); %& (x > 0.31);% & (sum < SUM2_WHITE);
    yImage = (sum > SUM1_WHITE); %& (y > 0.32); %& (sum < SUM2_WHITE);
    
    binImgWhite = xImage & yImage;
    figure;
    imshow(binImgWhite);
     
    title({'White color regions of the image'});
    