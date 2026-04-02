% Export pval_table to LaTeX
latexFile = fullfile(Figure_folder, Latexfile);
fid = fopen(latexFile, 'w');
if fid == -1
    error('Could not open file %s for writing.', latexFile);
end

nLeft=7;
nRight=8;

% Write LaTeX table header
fprintf(fid, '\\begin{sidewaystable}[ht]\n\\centering\n\\begin{tabular}{l%s}\n', repmat('c',1,nGroups));
fprintf(fid, '\\toprule\n');

% Header row
fprintf(fid, 'Image');
for k = 1:nGroups
    fprintf(fid, ' & %s', groups{k});
end
fprintf(fid, ' \\\\\n\\midrule\n');

% Table body
for i = 1:nGroups
    fprintf(fid, '%s', groups{i});
    for j = 1:nGroups
        val = pvals(i,j);
        if isnan(val)
            fprintf(fid, ' & n/a');
        elseif val<0.01
            fprintf(fid, ' & %.2e', val);
        else
            fprintf(fid, ' & %.4f', val);
        end
    end
    fprintf(fid, ' \\\\\n');
end

% Footer
fprintf(fid, '\\bottomrule\n\\end{tabular}\n');

fprintf(fid, '\\caption{\\textbf{Raw pairwise MANOVA p-values}. Note that p-values are not yet Bonferroni-corrected.}\n');
fprintf(fid, '\\label{tab:pvals_pairwise}\n\\end{sidewaystable}\n');


fclose(fid);
