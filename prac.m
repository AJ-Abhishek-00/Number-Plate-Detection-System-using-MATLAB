clc;
clear all;
close all;
cd test
input=uigetfile('*.*','slect a number plate');
input_image=imread(input);
cd ..
figure;
    imshow(input_image);
     
    title({'Original image'});
[white_region yello_region ext_image msg]=extract(input_image);
figure;
    imshow(yello_region);
     
    title({'Yellow color regions of the image'});
    figure;
    imshow(white_region);
     
    title({'White color regions of the image'});
    figure;
        imshow(ext_image);
        title('extracted number')
   pause(5)
   close all;
   pause(2)
if(msg == 1)
    h = msgbox('Commercial Vechicle','Image Classified');
    elseif(msg == 2)
        h = msgbox('Private Vechicle','Image Classified');
        else
        msgbox('number plate is an unautherised')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cmp_ext=mean(mean(ext_image));
ext_image=uint32(ext_image);
[m n d]=size(ext_image);
cmp_ext1=0;
cmp_ext2=0;
cmp_ext3=0;
for k=1:d
    for i=1:m
        for j=1:n
            if(k==1)
            cmp_ext1=cmp_ext1+ext_image(i,j,k);
            elseif(k==2)
                cmp_ext2=cmp_ext2+ext_image(i,j,k);
            else
                cmp_ext3=cmp_ext3+ext_image(i,j,k);
            end
        end
    end
end
cmp_ext=(((cmp_ext1+cmp_ext2+cmp_ext3)/3)/size(ext_image,1)*size(ext_image,2));
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
cd registered_vehicles
for i=1:11
    if(i>=2 & i<=5)
    name=strcat(num2str(i),'.jpeg');
    else
        name=strcat(num2str(i),'.jpg');
    end
    train_img=imread(name);
    train_features=train(train_img);
%     cmp_train=mean(mean(train_features));
train_features=uint32(train_features);
[m n d]=size(train_features);
cmp_train1=0;
cmp_train2=0;
cmp_train3=0;
for k=1:d
    for i=1:m
        for j=1:n
            if(k==1)
            cmp_train1=cmp_train1+train_features(i,j,k);
            elseif(k==2)
                cmp_train2=cmp_train2+train_features(i,j,k);
            else
                cmp_train3=cmp_train3+train_features(i,j,k);
            end
        end
    end
end
cmp_train=(((cmp_train1+cmp_train2+cmp_train3)/3)/size(train_features,1)*size(train_features,2));
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    if(cmp_train==cmp_ext)
        disp(name);
    break;
    end
end
cd ..

