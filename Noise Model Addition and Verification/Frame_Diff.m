% pngclc; clear; close all;                                     

dataPath = 'E:\Paper\1\mitsuba\8-22\';                          
savePath = 'E:\Paper\1\mitsuba\8-22\sim_output\';               

if ~exist(savePath,'dir')                                       
    mkdir(savePath);                                            
end                                                             


numGroups = 41;                                                 
theoryVel = 1.375 + 0.125*(1:numGroups);                        
trueVel = -theoryVel;                                           

T_exp_s = 8e-3;                                                 
gap_s = 22e-3;                                                  
dt = T_exp_s + gap_s;                                           

d0_m = 0.9;                                                     
rectAreaFraction = 0.4;                                         

fm_Hz = 100e6;                                                  
sigma_ref_m = 6e-3;                                             
Cd = 0.6;                                                       
d_ref_m = 0.9;                                                  
T_ref_s = 8e-3;                                                 


monteCarloTrials = 500;                                         
rgbTrialIndex = ceil(monteCarloTrials / 2);                     
confidenceLevel = 0.95;                                         
ciLowPercent = (1 - confidenceLevel) / 2 * 100;                 
ciHighPercent = (1 + confidenceLevel) / 2 * 100;                


representativeMode = 'original_random';                         


meanVel = zeros(1, numGroups);                                  
rmseVel = zeros(1, numGroups);                                  
maeVel  = zeros(1, numGroups);                                  

meanVelCI = zeros(numGroups, 2);                                
rmseVelCI = zeros(numGroups, 2);                                
maeVelCI  = zeros(numGroups, 2);                                

meanVelMC = zeros(monteCarloTrials, numGroups);                 
rmseVelMC = zeros(monteCarloTrials, numGroups);                 
maeVelMC  = zeros(monteCarloTrials, numGroups);                 

overallRMSE_MC = zeros(monteCarloTrials, 1);                    
overallMAE_MC  = zeros(monteCarloTrials, 1);                    
overallR2_MC   = zeros(monteCarloTrials, 1);                    

sigmaFrame1_m = zeros(1, numGroups);                            
sigmaFrame2_m = zeros(1, numGroups);                            

dStartFrame1_m = zeros(1, numGroups);                           
dEndFrame1_m   = zeros(1, numGroups);                           
dStartFrame2_m = zeros(1, numGroups);                           
dEndFrame2_m   = zeros(1, numGroups);                           

RsList = zeros(1, numGroups);                                   


vmin = -7;                                                         
vmax = 0;                                                          

customColormap = jet(256);                                         
customColormap(1,:) = [1 1 1];                                     

OUT_H = 512;                                                       
OUT_W = 512;                                                       



for i = 1:numGroups                                                

    currentValue = theoryVel(i);                                   

    filename1 = sprintf('%sdepth_map_run1_w512x512_f100MHz_T8.0ms_NT100_spp64_v1%.3f_v20.00.npy', dataPath, currentValue); 
    filename2 = sprintf('%sdepth_map_run2_w512x512_f100MHz_T8.0ms_NT100_spp64_v1%.3f_v20.00.npy', dataPath, currentValue); 

    frame1 = readNPY(filename1);                                  
    frame2 = readNPY(filename2);                                  

    mask1 = ~isnan(frame1);                                       
    mask2 = ~isnan(frame2);                                       
    validDepthMask = mask1 & mask2;                               

    [H, W] = size(frame1);                                        

    dStartFrame1_m(i) = d0_m;                                     
    dEndFrame1_m(i) = d0_m - currentValue * T_exp_s;              

    dStartFrame2_m(i) = d0_m - currentValue * (T_exp_s + gap_s);  
    dEndFrame2_m(i) = dStartFrame2_m(i) - currentValue * T_exp_s; 

    [sigmaFrame1_m(i), RsList(i)] = noise_one_exposure( ...       
        fm_Hz, currentValue, dStartFrame1_m(i), ...               
        sigma_ref_m, T_exp_s, Cd, d_ref_m, T_ref_s);              

    [sigmaFrame2_m(i), ~] = noise_one_exposure( ...               
        fm_Hz, currentValue, dStartFrame2_m(i), ...               
        sigma_ref_m, T_exp_s, Cd, d_ref_m, T_ref_s);              

    fprintf('Group %02d, v = %.3f m/s, sigma1 = %.3f mm, sigma2 = %.3f mm\n', ...
        i, currentValue, sigmaFrame1_m(i)*1e3, sigmaFrame2_m(i)*1e3); 

    velocityForRGB = NaN(H, W);                                    

    for mc = 1:monteCarloTrials                                    

        frame1Filtered = frame1;                                   
        frame2Filtered = frame2;                                   

        noise1 = sigmaFrame1_m(i) .* randn(size(frame1Filtered));  
        noise2 = sigmaFrame2_m(i) .* randn(size(frame2Filtered));  

        frame1Filtered(mask1) = frame1Filtered(mask1) + noise1(mask1); 
        frame2Filtered(mask2) = frame2Filtered(mask2) + noise2(mask2); 

        velocity = (frame2Filtered - frame1Filtered) / dt;        

        velocity(~validDepthMask) = NaN;                          

        maskFiltered = isfinite(velocity);                        

        switch representativeMode                                 

            case 'center_pixel'                                   
                centerRow = round(H / 2);                         
                centerCol = round(W / 2);                         
                meanVelMC(mc,i) = velocity(centerRow, centerCol); 

            otherwise                                             
                meanVelMC(mc,i) = pick_original_random_velocity( ...
                    velocity, validDepthMask, rectAreaFraction);    

        end                                                       

        rmseVelMC(mc,i) = sqrt(mean((velocity(maskFiltered) - trueVel(i)).^2, 'omitnan')); 
        maeVelMC(mc,i) = mean(abs(velocity(maskFiltered) - trueVel(i)), 'omitnan');        

        if mc == rgbTrialIndex                                     
            velocityForRGB = velocity;                             
        end                                                        

    end                                                            

    meanVel(i) = mean(meanVelMC(:,i), 'omitnan');                  
    rmseVel(i) = mean(rmseVelMC(:,i), 'omitnan');                  
    maeVel(i) = mean(maeVelMC(:,i), 'omitnan');                    

    meanVelCI(i,:) = calc_percentile_ci(meanVelMC(:,i), ciLowPercent, ciHighPercent); 
    rmseVelCI(i,:) = calc_percentile_ci(rmseVelMC(:,i), ciLowPercent, ciHighPercent); 
    maeVelCI(i,:)  = calc_percentile_ci(maeVelMC(:,i), ciLowPercent, ciHighPercent);  

    velocity = velocityForRGB;                                     

    titleStr = sprintf('  MC trial %d velocity diagram with \nactual velocity of %.3f m/s', rgbTrialIndex, currentValue); 

    outFile = sprintf('%svel_map_%02d.png', savePath, i);           

    save_velocity_rgb_png(velocity, customColormap, vmin, vmax, OUT_H, OUT_W, titleStr, outFile); 

end                                                                


for mc = 1:monteCarloTrials                                       

    overallRMSE_MC(mc) = sqrt(mean((meanVelMC(mc,:) - trueVel).^2, 'omitnan')); 

    overallMAE_MC(mc) = mean(abs(meanVelMC(mc,:) - trueVel), 'omitnan');        

    ss_res = nansum((meanVelMC(mc,:) - trueVel).^2);             

    ss_tot = nansum((trueVel - nanmean(trueVel)).^2);            

    overallR2_MC(mc) = 1 - (ss_res / ss_tot);                    

end                                                              

overallRMSE = mean(overallRMSE_MC, 'omitnan');                   
overallMAE = mean(overallMAE_MC, 'omitnan');                     
r_squared = mean(overallR2_MC, 'omitnan');                       

overallRMSE_CI = calc_percentile_ci(overallRMSE_MC, ciLowPercent, ciHighPercent); 
overallMAE_CI = calc_percentile_ci(overallMAE_MC, ciLowPercent, ciHighPercent);   
r_squared_CI = calc_percentile_ci(overallR2_MC, ciLowPercent, ciHighPercent);     


rmseScale = max(overallRMSE, eps);                             
maeScale = max(overallMAE, eps);                               
r2Scale = max(abs(r_squared), eps);                            

trialScore = ((overallRMSE_MC - overallRMSE) ./ rmseScale).^2 + ... 
             ((overallMAE_MC  - overallMAE ) ./ maeScale ).^2 + ... 
             ((overallR2_MC   - r_squared  ) ./ r2Scale  ).^2;      

[~, plotTrialIndex] = min(trialScore);                           

plotTrialRMSE = overallRMSE_MC(plotTrialIndex);                  
plotTrialMAE = overallMAE_MC(plotTrialIndex);                    
plotTrialR2 = overallR2_MC(plotTrialIndex);                      




figure('Color','w','Units','pixels','Position',[100 100 800 600]); 

flipped_groups = numGroups:-1:1;                                  
trueVel_abs_flipped = abs(trueVel(flipped_groups));                
groups_x = 0:(numGroups-1);                                       

meanVel_abs_flipped = abs(meanVelMC(plotTrialIndex, flipped_groups)); 

plot(groups_x, trueVel_abs_flipped, 'k--', 'LineWidth', 2);       
hold on;                                                         
plot(groups_x, meanVel_abs_flipped, 'rs-', 'LineWidth', 1.5, 'MarkerSize', 6); 

xlabel('Group Number');                                           
ylabel('Velocity (m/s)');                                        
legend('Actual Velocity','Calculation Velocity','Location','NorthEast'); 
title('Actual Velocity vs Representative Monte Carlo Calculation Velocity'); 
ylim([0, max([trueVel_abs_flipped, meanVel_abs_flipped]) * 1.1]);

ax = gca;                                                        
xlims = xlim(ax);                                                
ylims = ylim(ax);                                                
textX = xlims(1) + 0.50 * (xlims(2) - xlims(1));                 
textY = ylims(2) - 0.12 * (ylims(2) - ylims(1));                 

txt = sprintf('N_{MC} = %d\nRMSE = %.4f [%.4f, %.4f] m/s\nMAE  = %.4f [%.4f, %.4f] m/s\nR^2   = %.4f [%.4f, %.4f]', ...
              monteCarloTrials, ...
              overallRMSE, overallRMSE_CI(1), overallRMSE_CI(2), ...
              overallMAE, overallMAE_CI(1), overallMAE_CI(2), ...
              r_squared, r_squared_CI(1), r_squared_CI(2));       

text(textX, textY, txt, 'FontSize', 10, ...                       
    'BackgroundColor', 'w', 'EdgeColor', 'k', ...                 
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');   

print(sprintf('%sactual_vs_estimated_velocity', savePath), '-dpng', '-r300'); 

figure('Color','w','Units','pixels','Position',[150 150 800 600]); 
plot(theoryVel, sigmaFrame1_m*1e3, 'bo-', 'LineWidth', 1.8, 'MarkerSize', 6); 
hold on;                                                                      
plot(theoryVel, sigmaFrame2_m*1e3, 'rs-', 'LineWidth', 1.8, 'MarkerSize', 6); 

xlabel('Theoretical Velocity (m/s)');                            
ylabel('Depth Noise Standard Deviation (mm)');                   
legend('Frame 1 Noise','Frame 2 Noise','Location','NorthWest');  
title('Depth Noise Standard Deviation vs Theoretical Velocity'); 
grid on;                                                         

print(sprintf('%snoise_vs_theoretical_velocity', savePath), '-dpng', '-r300'); 


actualVelPlot = trueVel_abs_flipped;                             
calculationVelPlot = meanVel_abs_flipped;                        

save(sprintf('%svelocity_analysis.mat', savePath), ...           
     'trueVel', 'theoryVel', 'meanVel', 'meanVelCI', ...         
     'rmseVel', 'rmseVelCI', 'maeVel', 'maeVelCI', ...           
     'meanVelMC', 'rmseVelMC', 'maeVelMC', ...                   
     'overallRMSE', 'overallMAE', 'r_squared', ...               
     'overallRMSE_CI', 'overallMAE_CI', 'r_squared_CI', ...      
     'overallRMSE_MC', 'overallMAE_MC', 'overallR2_MC', ...      
     'plotTrialIndex', 'plotTrialRMSE', 'plotTrialMAE', 'plotTrialR2', ... 
     'actualVelPlot', 'calculationVelPlot', ...                   
     'sigmaFrame1_m', 'sigmaFrame2_m', 'RsList', ...               
     'dStartFrame1_m', 'dEndFrame1_m', 'dStartFrame2_m', 'dEndFrame2_m', ...
     'T_exp_s', 'gap_s', 'dt', ...                                 
     'fm_Hz', 'sigma_ref_m', 'Cd', 'd_ref_m', 'T_ref_s', ...       
     'monteCarloTrials', 'rgbTrialIndex', 'confidenceLevel', ...   
     'representativeMode');                                       

% ============================
% 保存独立 colorbar 图
% ============================
colorbarHeight = 2048;                                            
colorbarWidth = 160;                                              
colorbarImg = zeros(colorbarHeight, colorbarWidth, 3);            

display_vmin = 0;                                                 
display_vmax = 7;                                                 

for row = 1:colorbarHeight                                        

    normValue = (colorbarHeight - row) / (colorbarHeight - 1);    

    colorIdx = round(normValue * (size(customColormap, 1) - 2)) + 2; 

    colorIdx = max(2, min(size(customColormap, 1), colorIdx)); 

    baseColor = customColormap(colorIdx, :);                   

    for c = 1:colorbarWidth                                    
        colorbarImg(row, c, :) = baseColor;                    
    end                                                        

end                                                            

colorbarFile = sprintf('%scolorbar.png', savePath);            
imwrite(colorbarImg, colorbarFile, 'png');                     

fprintf('save：%s\n', savePath);                      



function [sigma_D_m, Rs] = noise_one_exposure(fm_Hz, v_toward_mps, d_start_m, sigma_ref_m, T_exp_s, Cd, d_ref_m, T_ref_s)

if nargin < 1 || isempty(fm_Hz)                                   
    fm_Hz = 100e6;                                                
end                                                               

if nargin < 2 || isempty(v_toward_mps)                            
    v_toward_mps = 3;                                             
end                                                               

if nargin < 3 || isempty(d_start_m)                               
    d_start_m = 0.9;                                              
end                                                               

if nargin < 4 || isempty(sigma_ref_m)                             
    sigma_ref_m = 6e-3;                                           
end                                                               

if nargin < 5 || isempty(T_exp_s)                                 
    T_exp_s = 8e-3;                                               
end                                                               

if nargin < 6 || isempty(Cd)                                      
    Cd = 0.6;                                                     
end                                                               

if nargin < 7 || isempty(d_ref_m)                                 
    d_ref_m = 0.9;                                                
end                                                               

if nargin < 8 || isempty(T_ref_s)                                 
    T_ref_s = 8e-3;                                               
end                                                               

c = 3e8;                                                          

if v_toward_mps < 0                                               
    error('v_toward_mps '); 
end                                                               

if d_start_m <= 0                                                 
    error('d_start_m');                                
end                                                               

if d_start_m - v_toward_mps * T_exp_s <= 0                      
    error(' 0'); 
end                                                             

if sigma_ref_m <= 0                                             
    error('sigma_ref_m ');                            
end                                                             

if T_exp_s <= 0 || T_ref_s <= 0                                 
    error('T_exp_s T_ref_s 。');                     
end                                                             

if Cd <= 0 || Cd > 1                                            
    error('Cd');                            
end                                                             

phase_to_depth_coeff = c / (4 * pi * fm_Hz);                    

G_ref_static = T_ref_s;                                         

Rs = (phase_to_depth_coeff / (sqrt(2) * Cd * sigma_ref_m))^2 / G_ref_static;

if v_toward_mps == 0                                               
    G_motion = T_exp_s * (d_ref_m / d_start_m)^2;                  
else                                                               
    d_end_m = d_start_m - v_toward_mps * T_exp_s;                  
    G_motion = d_ref_m^2 / v_toward_mps * (1 / d_end_m - 1 / d_start_m); 
end                                                               

Ns = Rs * G_motion;                                               

sigma_phi = 1 / (sqrt(2) * Cd * sqrt(Ns));                        

sigma_D_m = phase_to_depth_coeff * sigma_phi;                     

end                                                               



function value = pick_original_random_velocity(velocity, validDepthMask, rectAreaFraction)

[H, W] = size(velocity);                                          

validMask = validDepthMask & isfinite(velocity);                  

nonNaNIdx = find(validMask);                                      

countNonNaN = numel(nonNaNIdx);                                   

if countNonNaN == 0                                               
    value = NaN;                                                  
    return;                                                       
end                                                               

kernel = ones(1,1);                                               

velCopy = velocity;                                               

invalidMask = ~isfinite(velCopy);                                 

velCopy(invalidMask) = 0;                                         

sumConv = conv2(velCopy, kernel, 'same');                         

weightConv = conv2(double(~invalidMask), kernel, 'same');         

smoothedVel = sumConv ./ weightConv;                              

smoothedVel(weightConv == 0) = NaN;                               

[rows_all, cols_all] = ind2sub([H, W], nonNaNIdx);                

centerRow = mean(rows_all);                                       

centerCol = mean(cols_all);                                       

bboxW = max(cols_all) - min(cols_all) + 1;                        

bboxH = max(rows_all) - min(rows_all) + 1;                        

if bboxH == 0                                                     
    aspectRatio = 1;                                              
else                                                              
    aspectRatio = bboxW / bboxH;                                  
end                                                               

targetArea = max(1, round(rectAreaFraction * countNonNaN));       

rectW = max(1, round(sqrt(targetArea * aspectRatio)));            

rectH = max(1, round(targetArea / rectW));                        

if rectW * rectH < targetArea                                     
    rectH = rectH + ceil((targetArea - rectW*rectH) / rectW);     
end                                                               

halfW = floor(rectW / 2);                                         

halfH = floor(rectH / 2);                                         

r1 = round(centerRow) - halfH;                                    

r2 = r1 + rectH - 1;                                              

c1 = round(centerCol) - halfW;                                    

c2 = c1 + rectW - 1;                                              

r1 = max(1, r1);                                                  
c1 = max(1, c1);                                                  
r2 = min(H, r2);                                                  
c2 = min(W, c2);                                                  

if r2 < r1                                                        
    r2 = r1;                                                      
end                                                               

if c2 < c1                                                        
    c2 = c1;                                                      
end                                                               

rectMask = false(H, W);                                           

rectMask(r1:r2, c1:c2) = true;                                    

regionMask = rectMask & isfinite(smoothedVel);                    

if any(regionMask(:))                                             
    regionIdx = find(regionMask);                                 
    pick = regionIdx(randi(numel(regionIdx)));                    
    value = smoothedVel(pick);                                    
else                                                              
    fallbackMask = validMask & isfinite(smoothedVel);             
    if any(fallbackMask(:))                                       
        fallbackIdx = find(fallbackMask);                         
        pick2 = fallbackIdx(randi(numel(fallbackIdx)));           
        value = smoothedVel(pick2);                               
    else                                                          
        value = mean(velocity(validMask), 'omitnan');             
    end                                                           
end                                                               

end                                                               


function save_velocity_rgb_png(velocity, customColormap, vmin, vmax, OUT_H, OUT_W, titleStr, outFile)

[H, W] = size(velocity);                                           

cm = customColormap;                                               

M = size(cm,1);                                                    

scaled = (velocity - vmin) / (vmax - vmin);                        

idxMat = ones(H, W, 'uint16');                                     

validPixels = ~isnan(scaled) & (scaled >= 0) & (scaled <= 1);      

idxMat(validPixels) = uint16(floor(scaled(validPixels) * (M-2)) + 2); 

idxMat(~isnan(scaled) & scaled > 1) = M;                          

idxMat(~isnan(scaled) & scaled < 0) = 2;                          

rgb = ind2rgb(double(idxMat), cm);                                

[h_rgb, w_rgb, ~] = size(rgb);                                    

if h_rgb == OUT_H && w_rgb == OUT_W                               
    rgb_fixed = rgb;                                              
else                                                              
    rgb_fixed = ones(OUT_H, OUT_W, 3);                            
    start_r = floor((OUT_H - h_rgb)/2) + 1;                       
    start_c = floor((OUT_W - w_rgb)/2) + 1;                       

    if h_rgb > OUT_H                                              
        r_off = floor((h_rgb - OUT_H)/2);                         
        row_src = (1:OUT_H) + r_off;                              
    else                                                          
        row_src = 1:h_rgb;                                        
    end                                                           

    if w_rgb > OUT_W                                              
        c_off = floor((w_rgb - OUT_W)/2);                         
        col_src = (1:OUT_W) + c_off;                              
    else                                                          
        col_src = 1:w_rgb;                                        
    end                                                           

    if h_rgb > OUT_H                                              
        row_dst = 1:OUT_H;                                        
    else                                                          
        row_dst = start_r:(start_r + h_rgb - 1);                  
    end                                                           

    if w_rgb > OUT_W                                              
        col_dst = 1:OUT_W;                                        
    else                                                          
        col_dst = start_c:(start_c + w_rgb - 1);                  
    end                                                           

    rgb_fixed(row_dst, col_dst, :) = rgb(row_src, col_src, :);    

end                                                               

if exist('insertText','file') == 2                                

    pos = [round(OUT_W/2), 8];                                    

    rgb_uint8 = im2uint8(rgb_fixed);                              

    rgb_out = insertText(rgb_uint8, pos, titleStr, ...            
        'FontSize', 21, ...                                       
        'BoxColor', 'white', ...                                  
        'TextColor', 'black', ...                                 
        'BoxOpacity', 1, ...                                      
        'AnchorPoint', 'CenterTop');                              

else                                                              
    fig = figure('Visible','off','Units','pixels','Position',[50 50 OUT_W OUT_H],'Color',[1 1 1],'InvertHardcopy','off'); % 创建不可见图窗

    axes('Position',[0 0 1 1]);                                    

    imshow(rgb_fixed, 'Border','tight');                           

    axis off;                                                      

    text('Units','normalized','Position',[0.5, 0.02], 'String', titleStr, ... 
        'HorizontalAlignment','center', 'VerticalAlignment','top', ... 
        'FontSize',14, 'FontWeight','bold', ...                    
        'BackgroundColor','white', 'Margin', 4, 'EdgeColor','none'); 

    drawnow;                                                      

    F = getframe(fig);                                            

    rgb_out = F.cdata;                                            

    close(fig);                                                   

end                                                               

if isa(rgb_out,'uint8')                                           
    imwrite(rgb_out, outFile);                                    
else                                                              
    imwrite(im2uint8(rgb_out), outFile);                          
end                                                               

end                                                               


function ci = calc_percentile_ci(x, lowPercent, highPercent)

x = x(~isnan(x));                                            

x = sort(x(:));                                              

n = numel(x);                                                

if n == 0                                                    
    ci = [NaN, NaN];                                         
    return;                                                  
end                                                          

if n == 1                                                    
    ci = [x(1), x(1)];                                       
    return;                                                  
end                                                          

ciLow = interp_percentile_value(x, lowPercent);              

ciHigh = interp_percentile_value(x, highPercent);            

ci = [ciLow, ciHigh];                                        

end                                                          


function value = interp_percentile_value(sortedX, percentValue)

n = numel(sortedX);                                               

pos = 1 + (n - 1) * percentValue / 100;                           

idxLow = floor(pos);                                              

idxHigh = ceil(pos);                                              

if idxLow == idxHigh                                              
    value = sortedX(idxLow);                                      
else                                                              
    weightHigh = pos - idxLow;                                    
    weightLow = 1 - weightHigh;                                   
    value = weightLow * sortedX(idxLow) + weightHigh * sortedX(idxHigh); 
end                                                               

end                                                               