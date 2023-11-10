clc
close all
clear all

% Import the data
MODISData = readtable('US_Whs_MODIS_2008_2016.csv');
TowerData = readtable('AMF_US-Whs_BASE_HH_21-5_PB.xlsx','Sheet','Sheet1');

% Set Nodata value, and percent of allowable missing values from flux tower
% data
NoDataValue = -9999;
max_percent_missing = 20;

% Get Data from relavent columns
MODIS_ET_8day = table2array(MODISData(1,15:end))/10; % Not sure, but I think things are scaled wierd in the csv file
Tower_LE_30min  = table2array(TowerData(:,5));

% Set up timestamps for the Tower Data
Tower_LE_30min(Tower_LE_30min == NoDataValue) = NaN;
Tower_TimeStart  = num2str(table2array(TowerData(:,1)));
Tower_Years = str2num(Tower_TimeStart(:,1:4));
Tower_Months = str2num(Tower_TimeStart(:,5:6));
Tower_Days = str2num(Tower_TimeStart(:,7:8));
Tower_Hours = str2num(Tower_TimeStart(:,9:10));
Tower_Minutes = str2num(Tower_TimeStart(:,11:12));
Tower_TS_Start = datenum(Tower_Years,Tower_Months,Tower_Days,Tower_Hours,Tower_Minutes,zeros(size(Tower_Minutes)));

% Set up timestamps for the MODIS Data
MODIS_TS_Start = [];
MODIS_TS_End = [];
c = 0;
for y = 2008:2016
    for b = 1:46
        c = c+1;
        MODIS_TS_Start(c) = datenum(y,1,1)+(b-1)*8;
        MODIS_TS_End(c) = min(datenum(y,12,31),datenum(y,1,1)+(b-1)*8+8-1);
    end
end

% Convert flux tower data from Latent heat to accumulated ET/8day - Though
% note that on the last day of the year, it is not an 8 day period, but
% rather a period based on the # of remaining days in the year
Tower_ET_percent_missing = [];
Tower_ET_8day = [];
for c = 1:numel(MODIS_TS_Start)
    ndays = MODIS_TS_End(c) - MODIS_TS_Start(c);
    nseconds = (MODIS_TS_End(c)-MODIS_TS_Start(c))*86400;
    locs = Tower_TS_Start >= MODIS_TS_Start(c) & Tower_TS_Start < MODIS_TS_End(c);
    Tower_ET_percent_missing(c) = sum(isnan(Tower_LE_30min(locs))) / numel(Tower_LE_30min(locs))*100;
    Tower_ET_8day(c) = nanmean(Tower_LE_30min(locs)) * nseconds / 2260E3 / 1000 * 1000;
    
    % Account for last period not being 8 days (Estimate what 8 day ET
    % would be if the period were longer)
    if ndays < 8
        Tower_ET_8day(c) = Tower_ET_8day(c) / (ndays/8);
        MODIS_ET_8day(c) = MODIS_ET_8day(c) / (ndays/8);
    end
end
Tower_ET_8day(Tower_ET_percent_missing > max_percent_missing) = NaN;

% Plot the timeseries
f = figure;
set(f,'Position',[100 100 1200 400])
hold on
plot((MODIS_TS_Start+MODIS_TS_End)/2,Tower_ET_8day,'LineWidth',2,'DisplayName','Flux Tower')
plot((MODIS_TS_Start+MODIS_TS_End)/2,MODIS_ET_8day,'LineWidth',2,'DisplayName','MODIS')
datetick('x')
xlabel('Date')
ylabel('ET (mm/8 day)')
legend show
set(gca,'FontSize',14)



% Plot the scatterplot
f = figure;
x = Tower_ET_8day;
y = MODIS_ET_8day;
[xdata,ydata] = prepareCurveData(x,y);
[f,gof] = fit(xdata,ydata,'poly1');
hold on
plot(xdata,ydata,'.');
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
plot(xlimits,f(xlimits),'-r','LineWidth',2)
text(xlimits(1)+xlimits(2)*0.1,ylimits(1)+ylimits(2)*0.9,['m = ' num2str(f.p1,'%0.2f') 'x + ' num2str(f.p2,'%0.1f')],'FontSize',14);
text(xlimits(1)+xlimits(2)*0.1,ylimits(1)+ylimits(2)*0.8,['R^2 = ' num2str(gof.rsquare,'%0.2f')],'FontSize',14);
xlabel('Flux Tower ET (mm/8day)');
ylabel('MODIS ET (mm/8 day)');
xlim(xlimits)
ylim(ylimits)
title('MODIS vs Flux Tower ET')
set(gca,'FontSize',14)



