%% Make_ddm_data
% This script converts the Matlab data to a csv file
% subj_indx: subject_number
% stim: face-scene evidence
% response: face, scene
% rt: reaction time
% condition: Face, Scene
% MotCon: Whether the response was motivation consistent or inconsistent
% pupil: evoked pupil response
% baseline: baseline pupil diameter

%
% Two versions: 50% only and all data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                       Set Directories                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear mex
clear all

dirs.data = '../../data/2_pupil/behavPupil_zscore';
dirs.output = '../../data/1_behav';


Sub = [1:38];
nSub = length(Sub);

start_tp = 500;
end_tp = 1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Create CSV file                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DataAll = fopen(fullfile(dirs.output,sprintf('DataAll_pupil.csv')),'w+');
fprintf(DataAll,'subj_idx,stim,response,rt,condition,MotCon,pupil,baseline\n');

missedTrials = 0;

for i = 1:nSub
    sub = num2str(Sub(i));
    fprintf('Running Subject %s \n',sub);
    
    file_path = fullfile(dirs.data,sprintf('Subj%s.mat',sub));
    load(file_path);
    
    for block = 1:12
        
        thisData = Data{1,block};
        
        % Hack to change NaNs into 4s (because of error in presentation code (double digits)
        thisData.Cat(isnan(thisData.Cat)) = 3;
        thisData.Cat = round(thisData.Cat); 
        
        thisData.Cat(thisData.Cat == 1) = -1.5;
        thisData.Cat(thisData.Cat == 2) = -0.5;
        thisData.Cat(thisData.Cat == 3) = 0;
        thisData.Cat(thisData.Cat == 4) = 0.5;
        thisData.Cat(thisData.Cat == 5) = 1.5;
        
        block_type_orig = Parms.blocks_randomized(block);
        
        % Change block type such that -1 = Face, 0 = No Motivation, 1 = Scene
        switch block_type_orig
            case 1
                block_type = -1;
            case 2
                block_type = 1;
            case 3
                block_type = 0;
        end
        
        % Write each trial
        for t = 1:length(thisData.Cat)
            
            pupil = nanmean(thisData.pupilTC_Response(t, start_tp:end_tp)) - thisData.baseline(t);
            
            %Print all trials
            if isnan(thisData.Choice(t))
       
            elseif thisData.RT(t) < 0.100
                
            elseif isnan(pupil)
                                
            % elseif block_type == 0
                
            else
                
                
                MotCon = NaN;
                
                switch block_type
                    
                    case 0
                        MotCon = 0;
                        
                    case -1
                        
                        if thisData.Choice(t) == 0
                            
                            MotCon = 1;
                            
                        elseif thisData.Choice(t) == 1
                            
                            MotCon = -1;
                            
                        end
                        
                    case 1
                        
                        if thisData.Choice(t) == 1
                            
                            MotCon = 1;
                            
                        elseif thisData.Choice(t) == 0
                            
                            MotCon = -1;
                            
                        end
                        
                end
                
               fprintf(DataAll,'%s,%0.1f,%i,%0.4f,%i,%i,%0.3f,%0.3f\n', sub, thisData.Cat(t),thisData.Choice(t),thisData.RT(t),block_type,MotCon, pupil, thisData.baseline(t));
               
            end
                
        end 
 
    end

end

fclose(DataAll);