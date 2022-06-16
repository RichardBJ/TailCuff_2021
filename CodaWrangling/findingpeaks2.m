function [locf, useable]=findingpeaks2(openfile,title_Bar,start,index)
%create a data array variable 2 columns t in 1, value in2.
useable = true; 
close all;
starttime=start; %read just after this
maxHR=750; %13th January 600 -> 750
minRR=1/(maxHR/60);
minpeakwidth=0.004; %13th January 0.005 -> 0.004
%Too small surely should be!!
disp(openfile);
data=csvread(openfile,4,0);%read the csv, skip the first 4 rows.
allt=data(:,1);
t0=find(allt>starttime,1);
t=allt(t0:length(allt));
allrawy=data(:,3);
allrawy=allrawy(t0:length(allrawy));
p = polyfit(t,allrawy,15);
f1 = polyval(p,t);
%allrawy=detrend(allrawy,2);
fallrawy=allrawy-f1;
%fshp=1/(data(5,1)-data(4,1));
%fpass=0.5;
fallrawy=myfilter(fallrawy);
%plot(highpass(fallrawy,fpass,fshp));
% was horrid fallrawy = highpass(fallrawy,5,200); %%TRYING SECOND FILTER
rawy=data(t0:end,3);
frawy=fallrawy;
screensize = get( groot, 'Screensize' );
fig=figure('rend','painters','pos',[100 100 0.9*screensize(3) screensize(4)/2]);
subplot(2,1,1);
plot(t,rawy);
title(title_Bar);
maxtime=ceil(max(t)/2)*2;
xlim([start,maxtime]);
%[p,s,mu] = polyfit(t,frawy,6);
%f_y = polyval(p,t,[],mu);
%flat=frawy-f_y;
flat=frawy;
%a couple of filtering options
%flat= smooth(t,flat,7,'sgolay',5);  %just smooth to see what that would look like
% flat = gaussfilt(t,flat,10); 
subplot(2,1,2);
plot(t,flat);
hold on;
% shows on plt
findpeaks(flat,t,'MinPeakDistance',minRR,'MinPeakWidth', minpeakwidth);
%collects up the data
[pkf locf]=findpeaks(flat,t,'MinPeakDistance',minRR, 'MinPeakWidth',minpeakwidth);
hold off;
xlim([start,maxtime]);
%%no dont do this..
%data=locf+((index-1)*60);
dlmwrite ('masterout.csv', data, '-append');
%%do this instead
option=recordoptions();
    if (option==1)
    data=diff(locf);
    dlmwrite ('masterout.ibi', data, '-append');
    elseif (option==2)
        % Delete entire record
        locf=[0,0,0];
        useable=false;
        return 
        
    elseif (option==0)
        % Edit record 
        [pkf, locf]=edithow(fig,locf,pkf);
        subplot(2,1,2);
        plot(t,flat);
        hold on;
        plot(locf,pkf,'ro');
    end

end

%% Do What?
function [rtn]=recordoptions()
% Construct a questdlg with three options
choice = questdlg('Do what?', ...
	'Dessert Menu', ...
	'Accept Entire Record','Reject Entire Record', ...
     'Edit Record','Accept Entire Record');
% Handle response
switch choice
    case 'Accept Entire Record'
        disp([choice]);
        rtn = 1;
    case 'Reject Entire Record'
        disp([choice]);
        rtn = 2;
    case 'Edit Record'
        disp('Editing');
        rtn = 0;
end

end
%% Edit How
function [rtnp rtnl]=edithow(fig,locf,pkf)
% Construct a questdlg with three options

%% skip straight to crop!
[rtnp rtnl]=croprecord(fig,locf,pkf);
return
%% skip straight to crop!
choice = questdlg('Do what?', ...
	'Dessert Menu', ...
	'Crop','Add beats','Delete Beats');
% Handle response


switch choice
    case 'Crop'
        [rtnp rtnl]=croprecord(fig,locf,pkf);
          
    case 'Add beats'
        disp([choice]);
       
    case 'Delete Beats'
        disp('Editing');
       
end
end

%% Add Beats

function addbeats()
        
next=false;
while (next==false)
prompt={'Add beat (where, 0=no)?','NOTWORKING: Delete beat (which, 0=no)?','scrub file (-1), or move on (0)'};
dlg_title = 'Modify the beats quit or do next';
num_lines = 1;
def = {'0','0', '0'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
beatloc=str2double(answer{1});
deleteloc=str2double(answer{2});
instruction=str2double(answer{3});
if (beatloc > 0) 
    addbeat=true;
else addbeat=false;
end

if (deleteloc > 0) 
    delete=true;
else delete=false;
end

if (deleteloc ==0 && beatloc==0)
    if (instruction< -1) 
    scrub=true;
    next=false;
    else
    next=true;
    scrub=false;
    end
end

end

    end


%% Delete Beats
function detelebeats()
% if (addbeat==true)
% loclen=length(locs);
% locs(loclen+1)=beatloc;
% hold on;
% plot([beatloc beatloc],[-100 100], 'color','g');
% plot([13.5 13.5],[-100 100], 'color','r');
% hold off;
% addbeat=false;
% end
end

%% Crop Record
function [rtnp, rtnl] =croprecord(fig,locf,pkf)
% Get left extent
[c_info]=getcursorinfo(fig);
leftlim=c_info.Position(1);
%get right extent
[c_info]=getcursorinfo(fig);
rightlim=c_info.Position(1);
startlen=length(locf);
if (rightlim<leftlim)
    %oops got them the wrong way around!
    tempn=rightlim;
    rightlim=leftlim;
    leftlim=tempn;
end
locf=locf(locf>leftlim);
lhs=startlen-length(locf);
locf=locf (locf<rightlim);

rtnp=pkf((lhs+1):(lhs+length(locf)));
rtnl=locf;
%could count the number of points removed to plot nicely again seen
%we knew the starting length(locf) initially).
end