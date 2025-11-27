%% Femke van Beek, 01-10-2023, Prepare Betweter data

clear all; close all;clc;

data_directory = './All_data/';
savename = "All_data";
save_on = true;

all_files = dir(data_directory);
all_files = all_files([all_files.isdir]==false,:);

% %sort files properly before processing
% for f=1:length(all_files)
%     pat_pp = "_pp" + wildcardPattern + "_";
%     all_pp(f) = 
% end

for f=1:length(all_files)
    
    if(f==1)
       opts = detectImportOptions([data_directory,all_files(f).name]); 
    end
    
    opts.VariableTypes{1} = 'double';
    opts.VariableTypes{3} = 'double';  
    opts.VariableTypes{6} = 'double';  
    opts.VariableTypes{7} = 'double';
    
    T_temp=readtable([data_directory,all_files(f).name],opts);
    T_temp.pc(:) = str2double(all_files(f).name(3));
    T_temp.order(:) = [1:size(T_temp,1)];
    
    %determine which setting is the final setting that was chosen
    if(~isempty(T_temp))
        for s=1:size(T_temp,1)-1
           T_temp.final(s) = ~strcmp(T_temp.image(s),T_temp.image(s+1)); 
        end

        T_temp.final(size(T_temp,1)) = 1;
        T_temp.time(:) = [T_temp.time(:)] - T_temp.time(1);
    end
    
    %append everything together
    if(exist('Total','var')==1)
        %some files only have a header. Those we skip
        if(~isempty(T_temp))
            Total = vertcat(Total,T_temp);
        else
            disp('empty file');
        end
    else
        Total = T_temp;    
    end
    
end

%remove rows that were stoprows
Total(Total.age==999,:)=[];
%rename area variables to numbers 
Total.area([strcmp([Total.area],'small')])={'1'} ;
Total.area([strcmp([Total.area],'medium')])={'2'} ;
Total.area([strcmp([Total.area],'large')])={'3'} ;
Total = convertvars(Total,{'area'},'categorical');
Total.area = double(Total.area);

%sort table for proper participant order per pc, then renumber participants
Total = sortrows(Total,{'pc','pp'});
Total = renamevars(Total,"pp","pp_orig");
Total.pp_new = [Total.pc].*100+[Total.pp_orig];
new_pp=unique([Total.pp_new],'stable');

Total.time_new = Total.time;

for pp=1:length(new_pp)
   Total.pp_new(Total.pp_new==new_pp(pp))=pp;
   
   this_pp = Total(Total.pp_new==pp,:);
   this_pp.time_new(1) = NaN;
   for t=2:size(this_pp,1)
        this_pp.time_new(t) = this_pp.time(t)-this_pp.time(t-1);
   end

   Total.time_new(Total.pp_new==pp) = this_pp.time_new;
end



if(save_on==true)
save(savename,"Total");
end