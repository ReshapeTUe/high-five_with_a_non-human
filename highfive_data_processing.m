%% MATLAB Script for Betweter paper

clear all
close all
Figure_folder = '.\Figures\';


%% LOAD DATA

data_unscaled = readtable('Final_settings.csv');
data_unscaled = sortrows(data_unscaled);
group = data_unscaled.image;
[groupIdx,groups] = grp2idx(group);


%% MAKE 3D HEATMAPS:

% x = pressure
% y = area
% z = frequeccy

press=unique(data_unscaled.pres);
areas=unique(data_unscaled.area);
freqs=unique(data_unscaled.freq);
nP=numel(press);
nA=numel(areas);
nF=numel(freqs);
pp=[0:nP]+0.5;
aa=[0:nA]+0.5;
ff=[0:nF]+0.5;

xoffset=0;
yoffset=0;
zoffset=0.5;

fig3D=figure;
fig3D.Units = 'centimeters';
fig3D.PaperUnits = 'centimeters';
fig3D.Position = [3 3 8,10.75];
fig3D.PaperSize = [fig3D.OuterPosition([3,4])];
t=tiledlayout(4,3);

for a=[1 6 10 11 5 3 7 8 9 2 4 12 13]    % --> saves images in order that emphasizes clusters, with Worm as focus
    if a<13
        ax=nexttile;
        hold on
    else
        fig3D_focus=figure;
        fig3D_focus.Units = 'centimeters';
        fig3D_focus.PaperUnits = 'centimeters';
        fig3D_focus.Position = [3 3 7 6];
        fig3D_focus.PaperSize = [fig3D_focus.OuterPosition([3,4])];
        ax=axes;
        hold on
    end

    counts=groupcounts(data_unscaled(strcmp(data_unscaled.image,groups{a}),:),{'pres','area'},{0.5+[0 10 15 20 25 30],0.5+[0 1 2 3]},IncludeEmptyGroups=true);
    [X,Y]=meshgrid(pp,aa);
    cData = reshape(counts.GroupCount,nA,nP);
    cData=[cData;zeros(1,size(cData,2))];
    cData=[cData,zeros(size(cData,1),1)];
    Z=zeros(size(cData));
    s=surf(ax, X, Y, Z, 'CData', cData, 'FaceColor', 'flat', 'EdgeColor', 'k');

    counts=groupcounts(data_unscaled(strcmp(data_unscaled.image,groups{a}),:),{'pres','freq'},{0.5+[0 10 15 20 25 30],0.5+[-1 0 1 2 5 10 20 30]},IncludeEmptyGroups=true);
    [X,Y]=meshgrid(pp,ff);
    cData = reshape(counts.GroupCount,nF,nP);
    cData=[cData;zeros(1,size(cData,2))];
    cData=[cData,zeros(size(cData,1),1)];
    Z=zeros(size(cData));
    s=surf(ax, X, Z, Y, 'CData', cData, 'FaceColor', 'flat', 'EdgeColor', 'k');

    counts=groupcounts(data_unscaled(strcmp(data_unscaled.image,groups{a}),:),{'freq','area'},{0.5+[-1 0 1 2 5 10 20 30],0.5+[0 1 2 3]},IncludeEmptyGroups=true);
    [X,Y]=meshgrid(ff,aa);
    cData = reshape(counts.GroupCount,nA,nF);
    cData=[cData;zeros(1,size(cData,2))];
    cData=[cData,zeros(size(cData,1),1)];
    Z=zeros(size(cData));
    s=surf(ax, Z, Y, X, 'CData', cData, 'FaceColor', 'flat', 'EdgeColor', 'k');

    % Format 3D view (all images)
    view(3);
    clim([0 30]);
    set(ax,'CameraPosition',[25 25 25]);
    axis square
    box on
    grid on
    if a<13
        % Format figure (non-worm)
        ax.XLim=[0,nP+0.5];
        ax.XTick=[0:nP];
        ax.XTickLabel={};
        ax.YLim=[0,nA+0.5];
        ax.YTick=[0:nA];
        ax.YTickLabel={};
        ax.ZLim=[0,nF+0.5];
        ax.ZTick=[0:nF];
        ax.ZTickLabel={};
        set(ax,'FontSize',8);
        set(ax,'FontName','Arial');
    end
end
% save figure (non-Worm)
print(fig3D,[Figure_folder,'heatmaps3D_clusters'],'-dpdf','-vector');

% Format and save figure (worm)
c=colorbar;
c.Position=[0.8863 0.1347 0.0504 0.7720];
c.FontSize=8;
xlabel('pressure (kPa)');
ylabel('area (-)');
zlabel('frequency (Hz)');
ax.XLim=[0,nP+0.5];
ax.XTick=[0:nP];
ax.XTickLabel={'','10','15','20','25','30'};
ax.YLim=[0,nA+0.5];
ax.YTick=[0:nA];
ax.YTickLabel={'','S','M','L'};
ax.ZLim=[0,nF+0.5];
ax.ZTick=[0:nF];
ax.ZTickLabel={'','0','1','2','5','10','20','30'};
set(ax,'FontSize',8);
set(ax,'FontName','Arial');

print(fig3D_focus,[Figure_folder,'heatmaps3D_focus_Worm'],'-dpdf','-vector');


%% TRANSFORMATION BEFORE DOING STATISTICS

% Define the inverse normal transformation function
inverse_normal_transform = @(x) norminv((tiedrank(x) - 0.5) / length(x));

% Apply the transformation
data.pres = inverse_normal_transform(data_unscaled.pres);
data.freq = inverse_normal_transform(data_unscaled.freq);
data.area = inverse_normal_transform(data_unscaled.area);
Y = [data.area, data.freq, data.pres];

%%% Residual Normality Analysis

% Compute group means
groupMeans_area = grpstats(data.area, group, 'mean');
groupMeans_freq = grpstats(data.freq, group, 'mean');
groupMeans_pres = grpstats(data.pres, group, 'mean');

% Compute residuals
res_area = data.area - groupMeans_area(groupIdx);
res_freq = data.freq - groupMeans_freq(groupIdx);
res_pres = data.pres - groupMeans_pres(groupIdx);

% Visualize residuals
figure;
subplot(3,2,1); histogram(res_area,300); title('Histogram: Area Residuals');
subplot(3,2,2); qqplot(res_area); title('Q-Q Plot: Area Residuals');

subplot(3,2,3); histogram(res_freq,700); title('Histogram: Freq Residuals');
subplot(3,2,4); qqplot(res_freq); title('Q-Q Plot: Freq Residuals');

subplot(3,2,5); histogram(res_pres,500); title('Histogram: Pres Residuals');
subplot(3,2,6); qqplot(res_pres); title('Q-Q Plot: Pres Residuals');


%% PCA ON GROUP MEANS

means=[groupMeans_area,groupMeans_freq,groupMeans_pres];
means_centered=means-mean(means);
[coeff_means, score, latent, tsquared, explained,mu] = pca(means_centered);
disp(coeff_means);
expl=sum(explained(1:2));
disp(['percent variance in means data explained by PC_1 + PC_2: ', num2str(expl)]);

% Reduce to 2D for later use
Y_reduced = score(:, 1:2);


%% OVERALL MANOVA

maov=manova(group,Y);
disp(['p-value for multivariate [area, freq, pres] (manova): ', num2str(maov.stats.pValue(1))]);

% Given values from MANOVA output
F = maov.stats.F(1);
df_effect = maov.stats.DFNumerator(1);
df_error = maov.stats.DFDenominator(1);

% Calculate partial eta squared
eta_squared_partial = (F * df_effect) / (F * df_effect + df_error);

% Display result
fprintf('Partial eta squared: %.4f\n', eta_squared_partial);
fprintf('F_%.0f_%.0f: %.4f\n', df_effect,df_error,F);


%% PAIRWISE MANOVA WITH BONFERRONI CORRECTION

nGroups = length(groups);
pvals = nan(nGroups);
Fvalue = nan(nGroups);

for i = 1:nGroups
    for j = i+1:nGroups
        idx = strcmp(group, groups{i}) | strcmp(group, groups{j});
        Y_pair = Y(idx, :);
        group_pair = group(idx);
        maov = manova(group_pair,Y_pair);
        pvals(j,i) =  maov.stats.pValue(1);
        Fvalue(j,i) = maov.stats.F(1);
    end
end

% Convert to Latex table (raw)
Latexfile='pvals_table_MANOVA.tex';
Latex_table_sideways;

% Bonferroni correction
nComparisons = nGroups * (nGroups - 1) / 2
pvals_bonf = nan(size(pvals));
pvals_bonf(~isnan(pvals))=min(pvals(~isnan(pvals)) * nComparisons, 1000);
pvals=pvals_bonf;

% Convert to Latex table (corrected)
Latexfile='pvals_table_MANOVA_Bonf.tex';
Latex_table_sideways;

significant=~max(pvals_bonf>0.05);
Fdifferent=Fvalue(:,significant);
minF=min(Fdifferent(Fdifferent>0));
pdifferent=pvals_bonf(:,significant);
maxp=max(pdifferent(pdifferent>0));
disp(['images that are significantly different from all others, min F: ',num2str(minF),', max p: ',num2str(maxp)])
maxF=max(Fvalue(pvals_bonf>=0.05));
minp=min(pvals_bonf(pvals_bonf>=0.05));
disp(['images for which some combinations are not significant, min p: ',num2str(minp)])

% Create heatmap
wposX=100; wposY = 100;
heatmapLength = 500;
heatmapWidth=heatmapLength;
fig_pairwise=figure('Renderer', 'painters', 'Position', [wposX wposY heatmapWidth heatmapLength]);

h = heatmap(groups, groups, pvals_bonf, ...
    'Colormap', flip(parula), ...
    'ColorLimits', [0 0.05], ...
    'GridVisible', 'off',...
    'MissingDataColor', [0.75 0.75 0.75], ... % Set a color for missing data
    'MissingDataLabel','n/a');
% make square:
h.InnerPosition = [0.21 0.2 0.58 0.58];
set(gca,'FontSize',8)
set(gca,'FontName','Arial')
% access hidden properties:
hs = struct(h);
hs.Colorbar.Ticks = [0:0.01:0.05];
hs.Colorbar.TickLabels = {'0','0.01','0.02','0.03','0.04','\geq 0.05'};
ylabel(hs.Colorbar, 'p-value');
hs.Colorbar.Label.Units="normalized";
hs.Colorbar.Label.Position=[1,1.15,0];
hs.Colorbar.Label.Rotation=0;
hs.Colorbar.FontSize=8;
hs.MissingDataColorbar.FontSize=8;
ax2=axes(fig_pairwise,'Position',h.Position);
[x,y]=find(hs.ColorData>=0.05);
xlim([0,13])
ylim([0,13])
ax2.Color='w';
ax2.YColor='none';
ax2.XColor='none';
ax2.YDir="reverse";
cData=h.ColorData'
for x=1:13
    for y=x:13
        if y==x
            patch([0 0 1 1]+x-1,[0 1 1 0]+y-1,[0.75 0.75 0.75]);
        else
            patch([0 0 1 1]+x-1,[0 1 1 0]+y-1,cData(x,y));
        end
    end
end
colormap(flip(parula))
clim([0,0.05]);

% format and save figure
fig_pairwise.PaperUnits = 'centimeters';
fig_pairwise.PaperSize = [8.4 8.4];
fig_pairwise.Units="centimeters";
fig_pairwise.Position = [3 3 8.4 8.4];
print(fig_pairwise,[Figure_folder,'fig_pairwise'],'-dpdf');


%% MEAN HAPTIC CUES and CLUSTERING

[cidx,cmeans]=kmeans(Y_reduced,[],'start',Y_reduced([1 2 4 7 12 13],:));


%%% 2D PCA projection

markers={'^','v','>','o','diamond','square'};
colors=lines(6);

figPCA=figure;
ax=axes;
hold on

for i=1:6
    scatter(Y_reduced(cidx==i,1),Y_reduced(cidx==i,2),30,colors(i,:),'filled','Marker',markers{i});
end
tt=text(Y_reduced(:,1)+0.1,Y_reduced(:,2),groups,"FontSize",8,"FontName","Arial");

% manual label placement:
tt(1).Position= [-0.8227   -0.0138         0];
tt(2).Position= [0.9448    -0.4556         0];
tt(3).Position= [-0.2424   -0.1584         0];
tt(4).Position= [0.9330     0.0155         0];
tt(5).Position= [0.0706     0.3323         0];
tt(6).Position= [-1.3323    0.2134         0];
tt(7).Position= [-0.2747    0.0342         0];
tt(8).Position= [-0.1223    0.1294         0];
tt(9).Position= [0.5382    -0.0599         0];
tt(10).Position=[-1.0557   -0.2865         0];
tt(11).Position=[0.5977     0.2564         0];
tt(12).Position=[-0.7261    0.9787         0];
tt(13).Position=[-0.6341   -0.9551         0];

% format figure
xlabel('PC_1')
ylabel('PC_2')
xlim([-1.5 1.5]);
ylim([-1.1 1.1]);
axis square
grid on
box on
figPCA.Units = 'centimeters';
figPCA.PaperUnits = 'centimeters';
figPCA.Position = [3 3 8.4 8.5];
figPCA.PaperSize = figPCA.OuterPosition([3,4]);
ax.InnerPosition = [0.125 0.12 0.845 0.845]; % make square
set(gca,'FontSize',8);
set(gca,'FontName','Arial');
print(figPCA,[Figure_folder,'PCA'],'-dpdf');


%%% 2D Projections in parameter space

means_fig_size=[8.4 8.5];

% area--pressure
corr_ap=figure;
ax=axes;
hold on
plot([-2,2]*coeff_means(1,1),[-2,2]*coeff_means(3,1),'linewidth',1.75,'LineStyle','--','Color',[0.75 0.75 0.75]);
plot([-2,2]*coeff_means(1,2),[-2,2]*coeff_means(3,2),'linewidth',1.25,'LineStyle','-.','Color',[0.75 0.75 0.75]);
for i=1:6
    s=scatter(groupMeans_area(cidx==i,:),groupMeans_pres(cidx==i,:),30,colors(i,:),'filled','Marker',markers{i});
end
tt=text(groupMeans_area+0.03,groupMeans_pres,groups,"FontSize",8,"FontName","Arial");
% manual label placement
tPos =[-0.3947   -0.5013
        0.6153    0.0123
        0.0622   -0.0582
        0.4066    0.9343
        -0.0810    0.4567
        -0.9828   -0.3389
        0.3529    0.1603
        -0.2307    0.3507
        0.5670    0.3917
        -0.6208   -0.9149
        0.1330    0.5534
        -0.9308    0.3355
        -0.6183   -0.7988];
for i = 1:length(tt)
    set(tt(i), 'Position', [tPos(i,1), tPos(i,2), 0]);
end
xlabel('area');
ylabel('pressure');
axis square
grid on
box on
xlim([-1 1]);
ylim([-1 1]);
ax.InnerPosition = [0.125 0.12 0.845 0.845]; % make square
corr_ap.Units = 'centimeters';
corr_ap.PaperUnits = 'centimeters';
corr_ap.Position = [3 3 means_fig_size];
corr_ap.PaperSize = corr_ap.OuterPosition([3,4]);
set(gca,'FontSize',8);
set(gca,'FontName','Arial');
print(corr_ap,[Figure_folder,'corr_ap'],'-dpdf');

% area--frequency
corr_af=figure;
ax=axes;
hold on
plot([-2,2]*coeff_means(1,1),[-2,2]*coeff_means(2,1),'linewidth',1.75,'LineStyle','--','Color',[0.75 0.75 0.75]);
plot([-2,2]*coeff_means(1,2),[-2,2]*coeff_means(2,2),'linewidth',1.25,'LineStyle','-.','Color',[0.75 0.75 0.75]);
for i=1:6
    s=scatter(groupMeans_area(cidx==i,:),groupMeans_freq(cidx==i,:),30,colors(i,:),'filled','Marker',markers{i});
end
tt=text(groupMeans_area+0.03,groupMeans_freq,groups,"FontSize",8,"FontName","Arial");
% manual label placement
tPos =[-0.3977    0.5665
        0.6079   -0.6831
        -0.1795   -0.0564
        0.5872   -0.4732
        0.2638    0.1211
        -0.8052    0.5857
        0.3649    0.0134
        0.0201   -0.2173
        0.5581   -0.2529
        -0.9148    0.2854
        0.4495   -0.1016
        -0.6099    1.0670
        -0.6198   -0.5622];
for i = 1:length(tt)
    set(tt(i), 'Position', [tPos(i,1), tPos(i,2), 0]);
end
xlabel('area');
ylabel('frequency');
axis square
grid on
box on
xlim([-1 1]);
ylim([-0.8 1.2]);
ax.InnerPosition = [0.125 0.12 0.845 0.845]; % make square
corr_af.Units = 'centimeters';
corr_af.PaperUnits = 'centimeters';
corr_af.Position = [10 3 means_fig_size];
corr_af.PaperSize = corr_af.OuterPosition([3,4]);
set(gca,'FontSize',8);
set(gca,'FontName','Arial');
print(corr_af,[Figure_folder,'corr_af'],'-dpdf');

% pressure--frequency
corr_pf=figure;
ax=axes;
hold on
plot([-2,2]*coeff_means(3,1),[-2,2]*coeff_means(2,1),'linewidth',1.75,'LineStyle','--','Color',[0.75 0.75 0.75]);
plot([-2,2]*coeff_means(3,2),[-2,2]*coeff_means(2,2),'linewidth',1.25,'LineStyle','-.','Color',[0.75 0.75 0.75]);
for i=1:6
    s=scatter(groupMeans_pres(cidx==i,:),groupMeans_freq(cidx==i,:),30,colors(i,:),'filled','Marker',markers{i});
end
tt=text(groupMeans_pres+0.03,groupMeans_freq,groups,"FontSize",8,"FontName","Arial");
% manual label placement
tPos =[-0.6385    0.5904
        0.1378   -0.6145
        -0.2670   -0.0220
        0.5822   -0.4747
        0.2166    0.1420
        -0.3881    0.4752
        -0.1442    0.0701
        0.3717   -0.1532
        0.4366   -0.2678
        -0.8446    0.3392
        0.4938   -0.0628
        0.2715    1.0670
        -0.7897   -0.5622];
for i = 1:length(tt)
    set(tt(i), 'Position', [tPos(i,1), tPos(i,2), 0]);
end
xlabel('pressure');
ylabel('frequency');
axis square
grid on
box on
xlim([-1 1]);
ylim([-0.8 1.2]);
ax.InnerPosition = [0.125 0.12 0.845 0.845]; % make square
corr_pf.Units = 'centimeters';
corr_pf.PaperUnits = 'centimeters';
corr_pf.Position = [17 3 means_fig_size];
corr_pf.PaperSize = corr_pf.OuterPosition([3,4]);
set(gca,'FontSize',8);
set(gca,'FontName','Arial');
print(corr_pf,[Figure_folder,'corr_pf'],'-dpdf');


%% CORRELATION

[rhoS,pvalS]=corr(means,'Type','Spearman');
[RP,pvalP]=corr(means,'Type','Pearson');

disp('Spearman correlation:')
disp(rhoS);
disp('Pearson correlation:')
disp(RP);

disp('Spearman p-values:')
disp(pvalS);
disp('Pearson p-values:')
disp(pvalP);
