function tomoman_sg_refine_tomoalign_generate_tomogram_runscript(t,p)
%% will_novactf_generate_tomogram_runscript
% A function to generate a 'runscript' for running novaCTF on a tilt-stack.
% When run, the runscript first runs parallel processing of tilt-stacks via
% MPI; when the MPI job is completed, it finishes the tomogram by running
% novaCTF. The tomogram is then binned via Fourier cropping and the 
% intermediate files are deleted. 
%
% WW 01-2018

%% Initialize

%% Check for refined center (__FUTURE__: implement xaxis tilt based on motl)
% 
% if isfield(p,'mean_z')
%     tomo_idx = p.mean_z(1,:) == t.tomo_num; % Find tomogram index
%     mean_z = round(p.mean_z(2,tomo_idx));   % Parse mean Z value
%     cen_name = [t.stack_dir,'/sg_refine_tomoalign/refined_cen.txt'];
%     dlmwrite(cen_name,mean_z);
%     new_cen = ['DefocusShiftFile ',cen_name];
% else
%     new_cen = [];
% end
%     


%% Generate run script

% Open run script
rscript = fopen([t.stack_dir,'/sg_refine_tomoalign/run_tomoalign.sh'],'w');


% Write initial lines for submission on either local or hpcl700x (p.512g)
% 
% EDIT SK 27112019

switch p.queue
%     case 'p.hpcl67'
%         fprintf(rscript,['#!/bin/bash -l\n',...
%             '# Standard output and error:\n',...
%             '#SBATCH -e ' ,t.stack_dir,'/sg_refine_tomoalign/error_sg_refine_tomoalign\n',...
%             '#SBATCH -o ' ,t.stack_dir,'/sg_refine_tomoalign/log_sg_refine_tomoalign\n',...
%             '# Initial working directory:\n',...
%             '#SBATCH -D ./\n',...
%             '# Job Name:\n',...
%             '#SBATCH -J IMOD\n',...
%             '# Queue (Partition):\n',...
%             '#SBATCH --partition=p.hpcl67 \n',...
%             '# Number of nodes and MPI tasks per node:\n',...
%             '#SBATCH --nodes=1\n',...
%             '#SBATCH --ntasks=40\n',...
%             '#SBATCH --ntasks-per-node=40\n',...
%             '#SBATCH --cpus-per-task=1\n',...            %'#SBATCH --gres=gpu:2\n',...
%             '#\n',...
%             '#SBATCH --mail-type=none\n',...
%             '#SBATCH --mem 510000\n',...
%             '#\n',...
%             '# Wall clock limit:\n',...
%             '#SBATCH --time=168:00:00\n',...
%             'echo "setting up environment"\n',...
%             'module purge\n',...
%             'module load intel/18.0.5\n',...
%             'module load impi/2018.4\n',...
%             '#load module for your application\n',...
%             'module load FOURIER3D/06-10-20\n',...
%             'module load IMOD/4.11.1\n',...
%             'export IMOD_PROCESSORS=40\n']);                      % Get proper envionment; i.e. modules
        
    
    case 'p.hpcl8'
        fprintf(rscript,['#!/bin/bash -l\n',...
            '# Standard output and error:\n',...
            '#SBATCH -e ' ,t.stack_dir,'/sg_refine_tomoalign/error_sg_refine_tomoalign\n',...
            '#SBATCH -o ' ,t.stack_dir,'/sg_refine_tomoalign/log_sg_refine_tomoalign\n',...
            '# Initial working directory:\n',...
            '#SBATCH -D ./\n',...
            '# Job Name:\n',...
            '#SBATCH -J IMOD\n',...
            '# Queue (Partition):\n',...
            '#SBATCH --partition=p.hpcl8 \n',...
            '# Number of nodes and MPI tasks per node:\n',...
            '#SBATCH --nodes=1\n',...
            '#SBATCH --ntasks=1\n',...
            '#SBATCH --ntasks-per-node=1\n',...
            '#SBATCH --cpus-per-task=24\n',...
            '#SBATCH --gres=gpu:2\n',...
            '#\n',...
            '#SBATCH --mail-type=none\n',...
            '#SBATCH --mem 378880\n',...
            '#\n',...
            '# Wall clock limit:\n',...
            '#SBATCH --time=168:00:00\n',...
            'echo "setting up environment"\n',...
            'module purge\n',...
            'module load intel/18.0.5\n',...
            'module load impi/2018.4\n',...
            '#load module for your application\n',...
            'module switch IMOD/4.11.1\n',...
            'module switch TOMOALIGN/march2021\n',...
            'export IMOD_PROCESSORS=24']);                      % Get proper envionment; i.e. modules
%     case 'p.512g'
%         error('Oops!! 404');
%         fprintf(rscript,['#! /usr/bin/env bash\n\n',...
%             '#$ -pe openmpi 40\n',...            % Number of cores
%             '#$ -l h_vmem=128G\n',...            % Memory limit
%             '#$ -l h_rt=604800\n',...              % Wall time
%             '#$ -q ',p.queue,'\n',...                       %  queue
%             '#$ -e ',t.stack_dir,'/novactf/error_novactf\n',...       % Error file
%             '#$ -o ',t.stack_dir,'/novactf/log_novactf\n',...         % Log file
%             '#$ -S /bin/bash\n',...                      % Submission environment
%             'source ~/.bashrc\n\n',]);                      % Get proper envionment; i.e. modules

%     case 'p.192g'
%         error('Oops!! 404');
%         fprintf(rscript,['#! /usr/bin/env bash\n\n',...
%             '#$ -pe openmpi 16\n',...            % Number of cores
%             '#$ -l h_vmem=128G\n',...            % Memory limit
%             '#$ -l h_rt=604800\n',...              % Wall time
%             '#$ -q ',p.queue,'\n',...                       %  queue
%             '#$ -e ',t.stack_dir,'/novactf/error_novactf\n',...       % Error file
%             '#$ -o ',t.stack_dir,'/novactf/log_novactf\n',...         % Log file
%             '#$ -S /bin/bash\n',...                      % Submission environment
%             'source ~/.bashrc\n\n',]);                      % Get proper envionment; i.e. modules        
    case 'local'
        fprintf(rscript,['#!/usr/bin/env bash \n\n','echo $HOSTNAME\n','set -e \n','set -o nounset \n\n','export IMOD_PROCESSORS=10']);

    otherwise
        error('only "p.hpcl8" is supported for p.queue!!!!')
        
end
    

if p.justbin ~= 1
    % Run parallel scripts
    fprintf(rscript,['# Process stacks','\n']);
%     fprintf(rscript,['srun ',t.stack_dir,'/sg_refine_tomoalign/stack_process.sh\n\n']);

    fprintf(rscript,[t.stack_dir,'/sg_refine_tomoalign/stack_align.sh\n\n']);
    fprintf(rscript,[t.stack_dir,'/sg_refine_tomoalign/stack_process.sh\n\n']);


    % Rotate tomogram (Tomorec takes care of it)
    fprintf(rscript,['# Rotate tomogram about X','\n']);
    fprintf(rscript,['clip rotx ',p.main_dir,'/',num2str(t.tomo_num),'.rec ',p.main_dir,'/',num2str(t.tomo_num),'.rec','\n\n']);

    % Remove temporary files
    fprintf(rscript,['# Remove temporary files','\n']);
    fprintf(rscript,['rm -f ',p.main_dir,'/',num2str(t.tomo_num),'.rec~','\n']);
end


% Bin tomogram (__FUTURE__: Implement resample from CisTEM: a few times faster and multithreaded)
in_name = [p.main_dir,'/',num2str(t.tomo_num),'.rec'];  % Input tomogram name
for i = 1:numel(p.tomo_bin)

    % Ouptut tomogram name
    out_name = [p.bin_dir{i},'/',num2str(t.tomo_num),'.rec'];

    fprintf(rscript,['# Fourier crop tomogram by a factor of ',num2str(prod(p.tomo_bin(1:i))),'\n']);
    fprintf(rscript,[p.fcrop_vol,' ',...
                     '-InputFile ',in_name,' ',...
                     '-OutputFile ',out_name,' ',...
                     '-BinFactor ',num2str(p.tomo_bin(i)),' ',...
                     '-MemoryLimit ',num2str(p.fcrop_vol_memlimit),' ',...
                     '> ',t.stack_dir,'/sg_refine_tomoalign/binning_log.txt 2>&1','\n\n']);

    % Set for serial binning on next pass
    in_name = out_name;
end

% Close file and make executable
fclose(rscript);
system(['chmod +x ',t.stack_dir,'/sg_refine_tomoalign/run_tomoalign.sh']);




end


