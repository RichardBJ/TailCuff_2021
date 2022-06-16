clear;
warning ('off','all')
try
    delete 'combinedout.csv';
catch
    donothing =0;
end
warning ('on','all')
prompt = {'start at which record (cycle):'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'1'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
datas={};
prevdatas={};
folder_name = uigetdir('','Select output directory/folder');
dessert=1;
index=str2num(answer{1})-1;
loop=0;
while (dessert==true)
% Construct a questdlg with three options
%choice = questdlg('Would you like to continue?', ...
	%'Options',	'Yes','No','No');
% Handle response
choice='Yes';
    switch choice
        case 'Yes'
            index=index+1;
            text=strcat(' copy cycle',num2str(index));
            disp([choice ' copy cycle'])
            [datas,~,dessert]=ripcode(index,folder_name,prevdatas,loop);
            clear ripcode;
            clear prevdatas;
            prevdatas=datas;
            clear datas;
            %dessert = 1;
        case 'No'
            disp('OK sorry no way back from here!')
            dessert = false;
    end
loop=loop+1;
end
disp("Your're done")