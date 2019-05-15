% load and take specs of COPD
cd('C:\Users\User\Desktop\uni\II semester\DSP\RESPDATA\COPD'); 
files = dir;
count = 0;
for i = files'
    if length(i.name) > 4 && i.name(end-3:end) == ".wav"   % only read file if filename is greater then four and extension is '.wav'
        count = count+1;
        [f{count} fs{count}] = audioread(i.name);
         count101{1,count} = (i.name(1:3));
    end
end


for ii=1:numel(f)
spectrogram(f{1,ii},'yaxis');
colorbar('off')
set(gca,'Visible','off')
baseFileName = sprintf('Image # %d.png', ii);
fullFileName = fullfile('C:\Users\User\Desktop\uni\II semester\DSP\specs\A', baseFileName);
saveas(gcf, fullFileName);
end
 % load and take specs of Healthy data
cd('C:\Users\User\Desktop\uni\II semester\DSP\RESPDATA\Healthy'); 
files = dir;
count = 0;
for i = files'
    if length(i.name) > 4 && i.name(end-3:end) == ".wav"   % only read file if filename is greater then four and extension is '.wav'
        count = count+1;
        [f{count} fs{count}] = audioread(i.name);
         count101{1,count} = (i.name(1:3));
    end
end


for ii=1:numel(f)
spectrogram(f{1,ii},'yaxis');
colorbar('off')
set(gca,'Visible','off')
baseFileName = sprintf('Image # %d.png', ii);
fullFileName = fullfile('C:\Users\User\Desktop\uni\II semester\DSP\specs\B', baseFileName);
saveas(gcf, fullFileName);
end





 
