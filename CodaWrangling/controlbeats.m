disp('starting');
clear;
close all;
minbpm=290; %WAS 295
modebpms=0;
labels=0;
count=0;
warning('off','all');
try
delete('masterout.csv');
catch
    disp('all good');
end
warning('on','all');
masterpwr=zeros(100,1);
start=2;
[FileName,PathName] = uigetfile('*.csv','Select the csvs to work on','MultiSelect','on');
FileName = cellstr(FileName);  % Care for the correct type 
modebpms=zeros(1,length(FileName));
labels=zeros(1,length(FileName));
for file=1:length(FileName)
    count=count+1;
    curfile=fullfile(PathName,FileName{file});
    expression = '.csv';
    index = regexp(curfile,expression);
    outfile=curfile(1:index-1);
    record = getnumber(FileName{file});
    labels(1,file)=record;
    outfilerr=strcat(outfile,'NIBP.ibi');
    outfile=curfile(1:index-1);
    outfilepwr=strcat(outfile,'pwr.csv');
    [locf,useable]=findingpeaks2(curfile,FileName{file},start,file);
    if useable==false
        continue
    end
    rr=diff(locf);
    % going to make and fit a histogram
    figure('Name','(scaled) BPM')
    % histogram(60./rr,100)
    beats=60./rr;
    % Remove silly bpms
    beats=beats(beats>minbpm);
    % Now have to scale x -axis (beats) to allow a Beta fit
    scaler=max(beats)*1.1;
    beats=beats./scaler;
    dis=histfit(beats,20,'beta');
    pd=fitdist(beats,'beta');
    %So that should have given us a "nice" fit
    %and the fit parameters are stored in pd (prob distribution).
    %so a formula is needed to pull out the mode.

    if pd.b>=1
        modebpm=(pd.a-1)/(pd.a+pd.b-2);
        % and remember to scale that mode back to actual bpm :-)
        modebpm=modebpm*scaler;
        disp(['mode bpm:',num2str(modebpm)]);
        modebpms(1,file)=modebpm;
    else
        disp(pd)
    end

    rround=round((60./rr)./5).*5;
    disp("mode(rround)-whatever that is");
    disp(mode(rround));
    modeRR=1/(modebpm/60.0);
    pause(1);
    %%processed RRs
    proRR=zeros(length(rr),2);
    SD=std(rr);
    proclen=0;
    upp=modeRR+SD/2;
    low=modeRR-SD/2;
    minbps=minbpm/60.0;
    maxRR=1/minbps;
    if upp>maxRR
       upp=maxRR;
    end
    for i =1 : length(rr)
        if (rr(i)<upp && rr(i)>low)
            proclen=proclen+1;
            proRR(proclen,1)=locf(i);
            proRR(proclen,2)=rr(i);        
        end   
    end
    % disp(proRR);
    proRR= proRR(1:proclen,:);
    % disp(proRR);
    %%
    csvwrite(outfilerr,proRR);

    %%
    % ectopic=true;
    % while(ectopic)
    %  SD=std(rr);
    %  [MX, I]=max(rr);
    %  X=mean(rr);
    %     if MX>(X+3*SD)
    %     rr(I)=X;
    %     else
    %         ectopic=false;
    %     end
    %  
    % end
    %%
    %run a Lomb-Scargle FFT on the ibis...
    tm=locf(2:end);
    [pwr fq]=lomb([tm rr]);
    maxfq=2;
    edges=0:0.2:maxfq;
    sz=length(edges);
    sumfq=zeros(sz,1);
    if file==1
        powerset=zeros(sz,length(FileName)+1);
        powerset(:,1)=edges;
    end
    %so that is full resolution but compress this to 10ish bins
    for i=1:sz-1
        for j=1:length(fq)
             if (fq(j)>=edges(i))&&(fq(j)<edges(i+1))
                 sumfq(i)=sumfq(i)+pwr(j);
             end
        end
        edges(i)=(edges(i)+edges(i+1))/2; % make the x value the midpoint.
    end
   %now prepare for getting an average, by adding all the powers to
   %one array. Then at an end you can divide by n to get me BUT
   %another routine at the end will give you all the SD etc. if you
   %want that...
    edges=transpose(edges);
    for i=1:length(edges)
        masterpwr(i)=sumfq(i)+masterpwr(i);
    end
    masterpwr(length(edges)+1:end,:)=[];
    csvwrite(outfilerr,rr);
    csvwrite(outfilepwr,[edges, sumfq]);
   
    powerset(:,file+1)=sumfq; 

end
aaabpms=[labels;modebpms];
powerset=[edges,powerset];
aaapowerset=[[0,0,labels];powerset];
figure('Name','Power Analysis')
bar(edges,masterpwr);
csvwrite('masteribi.ibi', diff(csvread('masterout.csv')));
plot(csvread('masterout.ibi'));
%%
% if you want average power and SD from everything now run
%    getaveragepower.m
%%
disp("If you want average power and SD from everything now run getaveragepower.m" +...
    newline+"But, the powerset variable should have the means however"+...
    newline+"Note summary data in 'aaabpms' and 'aaapowerset' variables");
function num=getnumber(stringer)
    B = regexp(stringer,'\d*','Match');
    num=str2num(string(B));
end