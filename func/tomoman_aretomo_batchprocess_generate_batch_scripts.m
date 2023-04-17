function tomoman_aretomo_batchprocess_generate_batch_scripts(t,p,root_dir,script_name)
%% will_novactf_generate_batch_scripts
% A script to generate a set of scripts for batch tomogram reconstruction
% with novaCTF. 
%
% WW 01-2018

%% Initialize

% Number of tomograms to reconstruct
n_tomos = numel(t);

% Determine job parameters
job_array = will_job_array(n_tomos,p.n_comp);
n_jobs = size(job_array,1);
if n_jobs < p.n_comp
    switch n_jobs
        case 1
            disp(['ACHTUNG!!! Only 1 job is needed!!!']);
        otherwise
            disp(['ACHTUNG!!! Only ',num2str(n_jobs),' jobs are needed!!!']);
    end
end

%% Write job scripts

for i = 1:n_jobs
    
% Open batch script
bscript = fopen([root_dir,'/',script_name,'_',num2str(i),'.sh'],'w');
fprintf(bscript,['#!/usr/bin/env bash \n\n','echo $HOSTNAME\n','set -e \n','set -o nounset \n\n']);

% Set qsub jobid counter
c = 0;
        for j = job_array(i,2):job_array(i,3)

            % Write lines
            if c == 0   
                fprintf(bscript,['JOBID=$(sbatch ',t(j).stack_dir,'/AreTomo/run_AreTomo.sh',' 2>&1 | awk ','''','{print $(NF)}','''',')\n']);
                fprintf(bscript,['echo ''''  '''' ${JOBID}','\n']);
                %fprintf(bscript,['sbatch ',t(j).stack_dir,'/AreTomo/run_AreTomo.sh','\n']);
            else
                fprintf(bscript,['JOBID=$(sbatch --dependency=afterany:${JOBID} ',t(j).stack_dir,'/AreTomo/run_AreTomo.sh',' 2>&1 | awk ','''','{print $(NF)}','''',')\n']);
                fprintf(bscript,['echo ''''  '''' ${JOBID}','\n']);
                %fprintf(bscript,['sbatch ',t(j).stack_dir,'/AreTomo/run_AreTomo.sh','\n']);
            end
            c = c + 1;
        end


% Close batch script and make executable
fclose(bscript);
system(['chmod +x ',root_dir,'/',script_name,'_',num2str(i),'.sh']);

end

submit_all_filename = [root_dir,'/',script_name,'_all.sh'];
submit_file = fopen(submit_all_filename,'w');
for i = 1:n_jobs
    fprintf(submit_file,[root_dir,'/',script_name,'_',num2str(i),'.sh\n']);    
end
fclose(submit_file);
system(['chmod +x ',submit_all_filename]);
end
