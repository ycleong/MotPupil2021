%% averageTC
% Save average timecourses

close all
clear all

% Set Directories
dirs.behav = '../../data/1_behav';
dirs.behavET = '../../data/2_pupil/behavPupil_zscore';

% Set subjects
nSub = 38;

nSample = 1750;
MotCon_Onset_Group = NaN(nSub,nSample);
MotIncon_Onset_Group = NaN(nSub,nSample);
NonMot_Onset_Group = NaN(nSub, nSample);

nSample_Response = 2000;
MotCon_Response_Group = NaN(nSub,nSample_Response);
MotIncon_Response_Group = NaN(nSub,nSample_Response);
NonMot_Response_Group = NaN(nSub, nSample_Response);

nBlocks = 12;
nTrials = 25;

%% Extract timecourse
for i = 1:nSub
   
    sub = num2str(i);
    fprintf('Running Subject %s \n',sub);
    
    MotCon_TC_sub = [];
    MotIncon_TC_sub = [];
    NonMot_TC_sub = [];
    
    MotCon_TC_response_sub = [];
    MotIncon_TC_response_sub = [];
    NonMot_TC_response_sub =[];
    
    
    behav_path = dir(fullfile(dirs.behavET,sprintf('Subj%s.mat',sub)));
    thisData = load(fullfile(dirs.behavET,behav_path.name));
    
    for r = 1:12
        block_type = thisData.Data{1,r}.block_type_n;
                      
        switch block_type
            % Face block
            case 1
                % Biased Trials
                % Choice == 0 means chose face;
                % Choice == 1 means chose scene;
                
                motcon_trials = thisData.Data{1,r}.Choice == 0;
                motincon_trials = thisData.Data{1,r}.Choice == 1;
                
                MotCon_TC_sub = [MotCon_TC_sub; thisData.Data{1,r}.pupilTC(motcon_trials,:)];
                MotIncon_TC_sub = [MotIncon_TC_sub ; thisData.Data{1,r}.pupilTC(motincon_trials,:)];
                
                MotCon_TC_response_sub = [MotCon_TC_response_sub; thisData.Data{1,r}.pupilTC_Response(motcon_trials,:)];
                MotIncon_TC_response_sub = [MotIncon_TC_response_sub ; thisData.Data{1,r}.pupilTC_Response(motincon_trials,:)];
                
                
            % Scene block
            case 2
               
                motcon_trials = thisData.Data{1,r}.Choice == 1;
                motincon_trials = thisData.Data{1,r}.Choice == 0;
                
                MotCon_TC_sub = [MotCon_TC_sub; thisData.Data{1,r}.pupilTC(motcon_trials,:)];
                MotIncon_TC_sub = [MotIncon_TC_sub ; thisData.Data{1,r}.pupilTC(motincon_trials,:)];
                
                MotCon_TC_response_sub = [MotCon_TC_response_sub; thisData.Data{1,r}.pupilTC_Response(motcon_trials,:)];
                MotIncon_TC_response_sub = [MotIncon_TC_response_sub ; thisData.Data{1,r}.pupilTC_Response(motincon_trials,:)];
            
            % Unbiased block    
            case 3  
%                 unbiased_trials = thisData.Data{1,r}.Cat == 3;
                unbiased_trials = thisData.Data{1,r}.Cat > 0;
                NonMot_TC_sub = [NonMot_TC_sub; thisData.Data{1,r}.pupilTC(unbiased_trials,:)]; 
                NonMot_TC_response_sub = [NonMot_TC_response_sub; thisData.Data{1,r}.pupilTC_Response(unbiased_trials,:)]; 

        end
    end
    
    % average for each subject
    MotCon_Onset_Group(i,:) = nanmean(MotCon_TC_sub);
    MotIncon_Onset_Group(i,:) = nanmean(MotIncon_TC_sub);
    NonMot_Onset_Group(i,:) = nanmean(NonMot_TC_sub); 
    
    % average for each subject
    MotCon_Response_Group(i,:) = nanmean(MotCon_TC_response_sub);
    MotIncon_Response_Group(i,:) = nanmean(MotIncon_TC_response_sub);
    NonMot_Response_Group(i,:) = nanmean(NonMot_TC_response_sub); 

end

%% save 
save('../../data/2_pupil/regression/averageTC_zscore.mat', 'MotCon_Onset_Group', 'MotIncon_Onset_Group', 'NonMot_Onset_Group','MotCon_Response_Group','MotIncon_Response_Group','NonMot_Response_Group');


