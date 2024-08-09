clc;
clear all;
close all;
cd images
a=imread('peppers.png');
cd ..
figure,imshow(a);
rthresh=200;
gthresh=120;
bthresh=50;
[h w dimen]=size(a);
for i=1:h
    for j=1:w
            if((a(i,j,1)>=rthresh & a(i,j,2)>=gthresh) & a(i,j,3)<=50)
                a(i,j,1)=a(i,j,1);
                a(i,j,2)=a(i,j,2);
                a(i,j,3)=0;
            else
                a(i,j,1)=0;
                a(i,j,2)=0;
                a(i,j,3)=0;
                end
    end
end
figure,imshow(a),
 a= imdilate(a, strel('disk', 7));
figure,imshow(double(a)),title('yellow color image');
for i=1:h
    for j=1:w
        if(a(i,j,1) & a(i,j,2))
            bnr(i,j)=1;
        else
            bnr(i,j)=0;
        end
    end
end
bnr= bwlabel(bnr);
figure,imshow(double(bnr)),title('binary converted image');