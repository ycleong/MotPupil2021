%% regression pupil

close all
clear all

% Set Directories
dirs.behav = '../../data/1_behav';
dirs.behavET = '../../data/2_pupil/behavPupil_zscore';

% Set subjects
nSub = 38;
nTrials = 200;

nSample = 1750;
nSample_Response = 2000;

nReg = 6;
b_all = NaN(nReg,nSub,nSample);
b_response_all = NaN(nReg,nSub,nSample_Response);
regressors = {'MotCon','RT','Stim','Choice','Baseline','Intercept'};

meanRT = NaN(nSub,1);

nBlocks = 12;

for i = 1:nSub
    
    %% get regressors
    sub = num2str(i);
    fprintf('Running Subject %s \n',sub);
    
    StimLock_Sub = [];
    ResponseLock_Sub = [];
    MotCon_Sub = [];
    RT_Sub = [];
    Stim_Sub = [];
    Response_Sub = [];
    Baseline_Sub = [];
       
    behav_path = dir(fullfile(dirs.behavET,sprintf('Subj%s.mat',sub)));
    thisData = load(fullfile(dirs.behavET,behav_path.name));
    
    for r = 1:12
        block_type = thisData.Data{1,r}.block_type_n;
        
        Stim = thisData.Data{1,r}.Cat;
        
        Stim(Stim == 1) = -1.5;
        Stim(Stim == 2) = -0.5;
        Stim(Stim == 3) = 0;
        Stim(Stim == 4) = 0.5;
        Stim(Stim == 5) = 1.5;
        
        thisPupil = thisData.Data{1,r}.pupilTC;
        thisRT = thisData.Data{1,r}.RT;

        switch block_type
            % Face block
            case 1
                % Biased Trials
                % Choice == 0 means chose face;
                % Choice == 1 means chose scene;
                
                StimLock_Sub = [StimLock_Sub; thisPupil];
                ResponseLock_Sub = [ResponseLock_Sub; thisData.Data{1,r}.pupilTC_Response];
                RT_Sub = [RT_Sub; thisRT];
                Stim_Sub = [Stim_Sub; Stim];
                Response_Sub = [Response_Sub; thisData.Data{1,r}.Choice];
                Baseline_Sub = [Baseline_Sub; thisData.Data{1,r}.baseline];
                
                motcon_regressor = NaN(length(thisData.Data{1,r}.Choice),1);
                motcon_regressor(thisData.Data{1,r}.Choice == 0) = 1;
                motcon_regressor(thisData.Data{1,r}.Choice == 1) = 0;
                
                MotCon_Sub = [MotCon_Sub; motcon_regressor];
                 
            % Scene block
            case 2
                
                StimLock_Sub = [StimLock_Sub; thisPupil];
                ResponseLock_Sub = [ResponseLock_Sub; thisData.Data{1,r}.pupilTC_Response];
                RT_Sub = [RT_Sub; thisRT];
                Stim_Sub = [Stim_Sub; Stim];
                Response_Sub = [Response_Sub; thisData.Data{1,r}.Choice];
                Baseline_Sub = [Baseline_Sub; thisData.Data{1,r}.baseline];

                motcon_regressor = thisData.Data{1,r}.Choice;
                motcon_regressor(thisData.Data{1,r}.Choice == 1) = 1;
                motcon_regressor(thisData.Data{1,r}.Choice == 0) = 0;
                
                MotCon_Sub = [MotCon_Sub; motcon_regressor];

        end
    end
    
    %% Calculate mean RT
    meanRT(i,1) = nanmean(RT_Sub);  
    
    %% run regression model (stim_lock)
    for tp = 1:nSample
    
        y = StimLock_Sub*100;
        X = [MotCon_Sub, RT_Sub, Stim_Sub, Response_Sub, Baseline_Sub, ones(length(MotCon_Sub),1)];
        
        b(:,tp) = regress(y(:,tp),X);
    
    end
    
    % Save regression coefficients
    for reg = 1:nReg
        b_all(reg,i,:) = b(reg,:);
    end

    clear b
    clear y
    clear X
    
    %% run regression model (response_lock)
    for tp = 1:nSample_Response
        
        y = ResponseLock_Sub*100;
        X = [MotCon_Sub, RT_Sub, Stim_Sub, Response_Sub, Baseline_Sub, ones(length(MotCon_Sub),1)];        
        
        b(:,tp) = regress(y(:,tp),X);
        
    end
    
    for reg = 1:nReg
        b_response_all(reg,i,:) = b(reg,:);
    end
    
    clear b
    clear y
    clear X
    

end


%% save 
save('../../data/2_pupil/regression/coefficients_zscore.mat', 'b_all', 'b_response_all', 'regressors', 'meanRT');

