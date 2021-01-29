%% Plot coefficients
close all
clear all

% Set script functions
opts.computeStats = 0;
addpath(genpath('../utils'));

% Set Directories
dirs.results = '../../data/2_pupil/regression';
dirs.tc = '../../data/2_pupil/regression';

load(fullfile(dirs.results,'coefficients_zscore.mat'));
load(fullfile(dirs.tc,'averageTC_zscore.mat'));

% Plot timecourse for Beta_motcon
reg = 1;
reg_name = regressors{reg};

%% Compute or Load Stats
if opts.computeStats
    
    cluster_forming_thresh = 0.05;
    
    this_coef = squeeze(b_all(reg,:,:)); 
    this_comp = zeros(size(this_coef));
    
    % onset
    mask = zeros(length(this_coef),1);
    mask(251:1250) = 1;
    mask = logical(mask);

    this_coef_mask = this_coef(:,mask);
    this_comp_mask = this_comp(:,mask);
    
    [clusters_onset_masked, p_values_onset, t_sums_onset, permutation_distribution_onset] = ...
        permutest(this_coef_mask', this_comp_mask', 'true', ...
        cluster_forming_thresh, 10000, 'true');

    for i = 1:length(clusters_onset_masked)
        
        sig_cluster = zeros(sum(mask),1);
        sig_cluster(clusters_onset_masked{1,i}) = 1;
        
        clusters_onset{i,1} = zeros(length(this_coef),1);
        clusters_onset{i,1}(mask) = sig_cluster;

    end
    
    % response
    this_coef = squeeze(b_response_all(reg,:,:));
    this_comp = zeros(size(this_coef));
    
    mask = zeros(length(this_coef),1);
    mask(1:1000) = 1;
    mask = logical(mask);
    
    this_coef_mask = this_coef(:,mask);
    this_comp_mask = this_comp(:,mask);
    
    [clusters_response_masked, p_values_response, t_sums_response, permutation_distribution_response] = ...
        permutest(this_coef_mask', this_comp_mask', 'true', ...
        cluster_forming_thresh, 10000, 'true');
    
    for i = 1:length(clusters_response_masked)
        
        sig_cluster = zeros(sum(mask),1);
        sig_cluster(clusters_response_masked{1,i}) = 1;
       
        clusters_response{i,1} = zeros(length(this_coef),1);
        clusters_response{i,1}(mask) = sig_cluster;
        
    end
    
    
    save(fullfile(dirs.results,sprintf('averageTC_clusterstats_%s.mat',reg_name)), 'clusters_onset', 'p_values_onset', 'clusters_response', 'p_values_response');
    
else
    
    load(fullfile(dirs.results,sprintf('averageTC_clusterstats_%s.mat',reg_name)));
    
end

%% Set up plot
col_code(1,:) = [228,26,28]/255;
col_code(2,:) = [55,126,184]/255;

err_col_code(1,:) = [254,229,217]/255;
err_col_code(2,:) = [239,243,255]/255;

errline_col_code(1,:) = [252,174,145]/255;
errline_col_code(2,:) = [189,215,231]/255;

figure(1)
set(gcf,'Position',[100 100 900 600]);


%% Plot timecourse
% Onset
subplot(2,2,1);
hold on;

MotConTC = MotCon_Onset_Group;
MotIncon_TC = MotIncon_Onset_Group;

meanMotCon = nanmean(MotConTC);
meanMotIncon = nanmean(MotIncon_TC);

n = length(MotConTC);
SE_MotCon = nanstd(MotConTC)/sqrt(size(MotConTC,1));
SE_MotIncon = nanstd(MotIncon_TC)/sqrt(size(MotIncon_TC,1));

h = fill([(1:n)';(n:-1:1)'],[meanMotIncon(1,:)'-SE_MotIncon(1,:)';...
    meanMotIncon(1,n:-1:1)'+SE_MotIncon(1,n:-1:1)'],err_col_code(2,:));

h2 = fill([(1:n)';(n:-1:1)'],[meanMotCon(1,:)'-SE_MotCon(1,:)';...
    meanMotCon(1,n:-1:1)'+SE_MotCon(1,n:-1:1)'],err_col_code(1,:));

set(h,'facealpha',.5,'EdgeColor',errline_col_code(2,:),'LineWidth',2)
set(h2,'facealpha',.5,'EdgeColor',errline_col_code(1,:),'LineWidth',2)

plot(meanMotIncon,'color',col_code(2,:),'LineWidth',4);
plot(meanMotCon,'color',col_code(1,:),'LineWidth',4);

line([250 250], [-0.1 0.1], 'LineStyle','--', 'Color', 'black','LineWidth',2);

axis([0 1251 -0.09, 0.16]);
set(gca,'xtick',[250:250:2250],'xticklabel',[0:0.5:4]);
set(gca,'FontSize',14)

ylabel('Pupil diameter (Z)','FontSize',16);
xlabel('Time from stimulus (s)','FontSize',16);

% Response
subplot(2,2,2)
hold on

MotConTC = MotCon_Response_Group;
MotIncon_TC = MotIncon_Response_Group;

meanMotCon = nanmean(MotConTC);
meanMotIncon = nanmean(MotIncon_TC);

n = length(MotConTC);
SE_MotCon = nanstd(MotConTC)/sqrt(size(MotConTC,1));
SE_MotIncon = nanstd(MotIncon_TC)/sqrt(size(MotIncon_TC,1));

h = fill([(1:n)';(n:-1:1)'],[meanMotIncon(1,:)'-SE_MotIncon(1,:)';...
    meanMotIncon(1,n:-1:1)'+SE_MotIncon(1,n:-1:1)'],err_col_code(2,:));

h2 = fill([(1:n)';(n:-1:1)'],[meanMotCon(1,:)'-SE_MotCon(1,:)';...
    meanMotCon(1,n:-1:1)'+SE_MotCon(1,n:-1:1)'],err_col_code(1,:));

set(h,'facealpha',.5,'EdgeColor',errline_col_code(2,:),'LineWidth',2)
set(h2,'facealpha',.5,'EdgeColor',errline_col_code(1,:),'LineWidth',2)

plot(meanMotIncon,'color',col_code(2,:),'LineWidth',4);
plot(meanMotCon,'color',col_code(1,:),'LineWidth',4);

line([1000 1000], [-0.2 0.2], 'LineStyle','--', 'Color', 'black','LineWidth',2);

ylabel('Pupil diameter (Z)','FontSize',16);
xlabel('Time (s)','FontSize',16);

axis([0 1251 -0.09 0.16]);
set(gca,'xtick',[1:250:2001],'xticklabel',[-2:0.5:2]);
set(gca,'FontSize',14)

ylabel('Pupil diameter (Z)','FontSize',16);
xlabel('Time from response (s)','FontSize',16);

%% Plot Regression coefficients
% Onset
subplot(2,2,3);
hold on;

thisTC = squeeze(b_all(reg,:,:));

meanTC = mean(thisTC);
SE_TC = nanstd(thisTC)/sqrt(size(thisTC,1));

meanRT_point = (mean(meanRT) + 0.5) / 2 * 1000;

n = length(meanTC);

% Find where to plot significant stars
xmax = 1250;

[max_meanTC, max_meanTC_ind] = max(meanTC(1:xmax));
[min_meanTC, min_meanTC_ind] = min(meanTC(1:xmax));

y_axis_max = (max_meanTC + SE_TC(max_meanTC_ind)) * 1.15;
y_axis_min = (min_meanTC - SE_TC(min_meanTC_ind)) * 1.5;
sig_point_y = (max_meanTC + SE_TC(max_meanTC_ind)) * 1.05;


for i = 1:length(clusters_onset)
    sig_points = find(clusters_onset{i,1});
    y = ones(length(sig_points), 1) * sig_point_y; 
    scatter(sig_points, y,30,[0,0,0],'filled');
end

h = fill([(1:n)';(n:-1:1)'],[meanTC(1,:)'-SE_TC(1,:)';...
     meanTC(1,n:-1:1)'+SE_TC(1,n:-1:1)'],[0.6, 0.6, 0.6]);

set(h,'facealpha',.25,'EdgeColor',[0.7, 0.7, 0.7],'LineWidth',2)

plot(meanTC,'color',[0,0,0],'LineWidth',4);

line([250 250], [y_axis_min y_axis_max], 'LineStyle','--', 'Color', 'black','LineWidth',2);

axis([1 xmax+1 y_axis_min y_axis_max]);
set(gca,'xtick',[250:250:2250],'xticklabel',[0:0.5:4]);
set(gca,'FontSize',14)

ylabel('Beta','FontSize',16);
xlabel('Time from stimulus onset(s)','FontSize',16);

% Response
subplot(2,2,4);
hold on;

thisTC = squeeze(b_response_all(reg,:,:));

meanTC = mean(thisTC);
SE_TC = nanstd(thisTC)/sqrt(size(thisTC,1));

n = length(meanTC);

for i = 1:length(clusters_response)
    sig_points = find(clusters_response{i,1});
    y = ones(length(sig_points), 1) * sig_point_y; 
    scatter(sig_points, y,30,[0,0,0],'filled');
end

h = fill([(1:n)';(n:-1:1)'],[meanTC(1,:)'-SE_TC(1,:)';...
     meanTC(1,n:-1:1)'+SE_TC(1,n:-1:1)'],[0.6,0.6,0.6]);

set(h,'facealpha',.25,'EdgeColor',[0.7,0.7,0.7],'LineWidth',2)

plot(meanTC,'color',[0,0,0],'LineWidth',4);

line([1000 1000], [y_axis_min y_axis_max], 'LineStyle','--', 'Color', 'black','LineWidth',2);

axis([1 xmax+1 y_axis_min y_axis_max]);
set(gca,'xtick',[1:250:2001],'xticklabel',[-2:0.5:2]);
set(gca,'FontSize',14)

ylabel('Beta','FontSize',16);
xlabel('Time from response (s)','FontSize',16);

% fig_dest = sprintf('../../figures/Regression_%s_zscore',reg_name);
% set(gcf,'paperpositionmode','auto');
% print('-depsc',fig_dest);

%% Print out stats
% onset
stim_cluster = find(clusters_onset{1,1});
stim_cluster_period(1,1) = stim_cluster(1);
stim_cluster_period(1,2) = stim_cluster(end);
stim_cluster_period = (stim_cluster_period - 250) * 2;

fprintf('%i ms to %i ms after stimulus onset, cluster p = %0.3f \n',stim_cluster_period,p_values_onset);

% response
response_cluster = find(clusters_response{1,1});
response_cluster_period(1,1) = response_cluster(1);
response_cluster_period = (response_cluster_period - 1000) * 2;

fprintf('%i ms from response, cluster p = %0.3f \n',response_cluster_period,p_values_response);





