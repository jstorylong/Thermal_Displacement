% 
%
% Read in the oisst_mhw_90perc_1982-2019_detrended.mat file you just made,
% extract information within GOA bounds and save as new .mat that you can
% read in more quickly.
% Then, extract mean and stdev stats within the OSP box to show periods of
% MHW (save as a vector of SST anom, and MHW definitions)
%
% Jacki Long (MBARI) 02 Nov 2020

% Extract a region from the Jacox MHW data
clear all
fn = '/Users/jlong/Documents/Data/Jacox_2020_copied02Nov2020/oisst_mhw_90perc_1982-2019_detrended.mat';
fn = '/Users/jlong/Documents/Data/Jacox_2020_copied02Nov2020/oisst_an_1982-2019.mat';

% load(fn)

% Look at variables
whos('-file',fn);
% Save a struct
clear D; D=matfile(fn);

res = 1./(size(D.lat,2)./180);
lat = [-90+(res/2):res:90-(res/2)];
lon = [0+(res/2):res:360-(res/2)];
% Set the area of the map
r3lat = [-90 90];
r3lon = [0 360];

% Make a map to see orientation
figure(1);clf
clear data; data = D.sst_an(:,:,10);
m_proj('Robinson','long',r3lon,'lat',r3lat);hold on
m_pcolor(lon,lat,((data')))
m_coast('patch',rgb('lightgrey'));
m_grid('box','fancy','tickdir','in','XaxisLocation','bottom');
caxis([0 2]);
cbh = colorbar;
colormap('jet')

%% Extract regionally averaged timeseries
roi = [48.5 53 -151.5+360 -139+360];
lat_idx = find(lat <= roi(2) & lat >= roi(1));
lon_idx = find(lon <= roi(4) & lon >= roi(3));


% Make a map to see orientation
figure(1);clf
clear data; data = D.sst_an(:,:,10);
m_proj('Robinson','long',r3lon,'lat',r3lat);hold on
m_pcolor(lon(lon_idx),lat(lat_idx),data(lon_idx,lat_idx,1)')
m_coast('patch',rgb('lightgrey'));
m_grid('box','fancy','tickdir','in','XaxisLocation','bottom');
caxis([0 2]);
cbh = colorbar;
colormap('jet')

% Grab a subset
for i = 1:size(D,'sst_an',3)
    %% Save data averaged over ROI
    % SST anomaly
    sst_anom_mn(i,1) = nanmean(reshape(D.sst_an(lon_idx,lat_idx,i),length(lon_idx).*length(lat_idx),1));
    % Detrended SST anomaly
    sst_anom_detrend(i,1) = nanmean(reshape(D.sst_an_dt(lon_idx,lat_idx,i),length(lon_idx).*length(lat_idx),1));
    % Datetime
    if D.month(1,i) < 10
        sst_anom_dt(i,1) = datenum(['0' num2str(D.month(:,i)), '15', num2str(D.year(:,i))], 'mmddyyyy');
    else
        sst_anom_dt(i,1) = datenum([num2str(D.month(:,i)), '15', num2str(D.year(:,i))], 'mmddyyyy');
    end
end

plot(sst_anom_dt,sst_anom_detrend,'k-+'); hold on
datetick('x')

save('/Users/jlong/Documents/Data/Jacox_2020_copied02Nov2020/OSP_extracted_sst_anom.mat','sst_anom_mn','sst_anom_detrend','sst_anom_dt')
