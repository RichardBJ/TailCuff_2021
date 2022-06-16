function [datas,thismax,cont] =ripcode(index,folder_name, lastdata,loop)
helptext=strcat('copy cycle : ',num2str(index),' *then* OK then wait!! OR just OK to quit');
%uiwait(helpdlg(helptext));
waitfor(msgbox(helptext));
tic
offset=3;
datas=clipboard('paste');
cont=true;
thismax=0;

if isequal(datas,lastdata)||isempty(datas)
    %ERROR!!!
    button = questdlg('Duplicate or empty!! Need to quit!', ...
        'Exit Dialog','Yes','No','Yes');
    cont=false;
    switch button
            case 'Yes'
              disp('Exiting program PLEASE WAIT!!!');
              %error('halting (may be deliverate, but only way out of loop!');
              % exit seems to shut Matlab entirely!
              return
              case 'No'
              %quit anyway!
              disp('Exiting program PLEASE WAIT!!!');
              %error('halting');
              return
    end
end
clear lastdata;
A = strsplit(datas,'\n');
A=transpose(A);
A(1:offset)=[];

%% old version
% This is a slow way of doing it, but only one I can find!
M=zeros(length(A)-1,3);
for i=1:length(A)-1
  B=strsplit(A{i},',');
  M(i,1)=str2double(B(1));
  M(i,2)=str2double(B(2));
  M(i,3)=str2double(B(3));
end

clear A;
clear B;
%% Now Outputting
if index <10
    outfilename=strcat('output0',num2str(index),'.csv');
else
     outfilename=strcat('output',num2str(index),'.csv');
end
fileout = fullfile(folder_name,outfilename);
csvwrite(fileout,M);
%% and a megaone
megaone=false;
if megaone==true
    thismax=0;
    fileout = fullfile(folder_name,'combinedout.csv');
    if loop >0
        O=csvread(fileout);
        times=O(:,1); 
        thismax=max(times');
        M(:,1)=M(:,1)+thismax+0.05;
        M=[O;M];
    end
    dlmwrite(fileout,M,'precision','%10.10f')
    %dlmwrite('combinedout.csv',M,'delimiter',',','-append','precision','%10.10f')
    clear O;
end

    %%
clear M;

close all;
toc
end

