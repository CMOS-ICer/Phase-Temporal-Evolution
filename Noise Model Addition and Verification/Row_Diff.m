% pngclc; clear; close all;                                          

dataPath = 'E:\Paper\1\mitsuba_odd\8-80\';                           
savePath = 'E:\Paper\1\mitsuba_odd\8-80\sim_output\';                

if ~exist(savePath,'dir')                                            
    mkdir(savePath);                                                 
end                                                                  

numGroups = 41;                                                      
dt = 0.036;                                                          

monteCarloTrials = 500;                                              
rgbTrialIndex = ceil(monteCarloTrials / 2);                          
confidenceLevel = 0.95;                                              
ciLowPercent = (1 - confidenceLevel) / 2 * 100;                      
ciHighPercent = (1 + confidenceLevel) / 2 * 100;                     

theoryVel = 1.375 + 0.125*(1:numGroups);                             
trueVel = -theoryVel;                                                

rectAreaFraction = 0.4;                                              

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

sigmaShort_m = zeros(1, numGroups);                                  
sigmaLong_m  = zeros(1, numGroups);                                  
RsList = zeros(1, numGroups);                                        

vmin = -7;                                                           
vmax = 0;                                                            

customColormap = jet(256);                                           
customColormap(1,:) = [1 1 1];                                       

OUT_H = 512;                                                         
OUT_W = 512;                                                         

for i = 1:numGroups                                                  

    currentValue = theoryVel(i);                                     
    filename1 = sprintf('%s%.3f.npy', dataPath, currentValue);       

    frame1 = readNPY(filename1);                                     
    mask1 = ~isnan(frame1);                                          

    [sigma_D_short_m, sigma_D_long_m, Rs] = noise([], currentValue); 

    sigmaShort_m(i) = sigma_D_short_m;                               
    sigmaLong_m(i)  = sigma_D_long_m;                                
    RsList(i) = Rs;                                                  

    velocityForRGB = NaN(OUT_H, OUT_W);                              

    for mc = 1:monteCarloTrials                                      

        frame1Filtered = frame1;                                     

        noise1 = sigma_D_short_m .* randn(size(frame1Filtered));     
        noise2 = sigma_D_long_m  .* randn(size(frame1Filtered));     

        frame1Filtered(1:2:end,:) = frame1Filtered(1:2:end,:) + noise1(1:2:end,:); 
        frame1Filtered(2:2:end,:) = frame1Filtered(2:2:end,:) + noise2(2:2:end,:); 

        velocity1 = zeros(256,512);                                            
        velocity2 = zeros(255,512);                                            
        velocity = zeros(512,512);                                             

        for row = 2:2:512                                                      
            if(row < 512)                                                      
                velocity1(row/2,:) = (frame1Filtered(row,:) - frame1Filtered(row-1,:)) / dt; 
                velocity2(row/2,:) = (frame1Filtered(row,:) - frame1Filtered(row+1,:)) / dt; 
            else                                                               
                velocity1(row/2,:) = (frame1Filtered(row,:) - frame1Filtered(row-1,:)) / dt; 
            end                                                                
        end                                                                    

        velocity(1:2:512,:) = velocity1(1:256,:);                              
        velocity(2:2:510,:) = velocity2(1:255,:);                              
        velocity(512,:) = NaN;                                                 

        mask = mask1;                                                          

        maskFiltered = ~isnan(velocity);                                       

        meanVelMC(mc,i) = velocity(256,256);                                   

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

    titleStr = sprintf('  MC trial %d velocity diagram with \nactual velocity of %.2f m/s', rgbTrialIndex, currentValue); 

    if exist('insertText','file') == 2                                        
        pos = [round(OUT_W/2), 8];                                            
        boxColor = 'white';                                                   
        textColor = 'black';                                                  
        rgb_uint8 = im2uint8(rgb_fixed);                                      
        rgb_with_title = insertText(rgb_uint8, pos, titleStr, ...             
            'FontSize', 21, ...                                               
            'BoxColor', boxColor, ...                                         
            'TextColor', textColor, ...                                       
            'BoxOpacity', 1, ...                                              
            'AnchorPoint', 'CenterTop');                                      
        rgb_out = rgb_with_title;                                             
    else                                                                      
        fig = figure('Visible','off','Units','pixels','Position',[50 50 OUT_W OUT_H],'Color',[1 1 1],'InvertHardcopy','off'); 
        axes('Position',[0 0 1 1]);                                            
        imshow(rgb_fixed, 'Border','tight');                                   
        axis off;                                                              
        text('Units','normalized','Position',[0.5, 0.02], 'String', titleStr, ... 
            'HorizontalAlignment','center', 'VerticalAlignment','top', ...    
            'FontSize',14, 'FontWeight','bold', ...                           
            'BackgroundColor','white', 'Margin', 4, 'EdgeColor','none');      
        drawnow;                                                              
        F = getframe(fig);                                                    
        imgCaptured = F.cdata;                                                
        close(fig);                                                           

        [hc, wc, ~] = size(imgCaptured);                                      

        if hc == OUT_H && wc == OUT_W                                         
            rgb_out = imgCaptured;                                            
        else                                                                  
            canvas = uint8(255*ones(OUT_H, OUT_W, 3));                        
            row_src = 1:hc;                                                   
            col_src = 1:wc;                                                   

            if hc > OUT_H                                                     
                r_off = floor((hc - OUT_H)/2);                                
                row_src = (1:OUT_H) + r_off;                                  
                row_dst = 1:OUT_H;                                            
            else                                                              
                row_dst = floor((OUT_H - hc)/2) + (1:hc);                     
            end                                                               

            if wc > OUT_W                                                     
                c_off = floor((wc - OUT_W)/2);                                
                col_src = (1:OUT_W) + c_off;                                  
                col_dst = 1:OUT_W;                                            
            else                                                              
                col_dst = floor((OUT_W - wc)/2) + (1:wc);                     
            end                                                               

            canvas(row_dst, col_dst, :) = imgCaptured(row_src, col_src, :);   
            rgb_out = canvas;                                                 
        end                                                                   
    end                                                                       

    outFile = sprintf('%svel_map_%02d.png', savePath, i);                     

    if isa(rgb_out,'uint8')                                                   
        imwrite(rgb_out, outFile);                                            
    else                                                                      
        imwrite(im2uint8(rgb_out), outFile);                                  
    end                                                                       

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

groups_x = 0:(numGroups-1);                                                   

trueVel_abs_flipped = abs(trueVel(flipped_groups));                           

meanVel_abs_flipped = abs(meanVelMC(plotTrialIndex, flipped_groups));         

plot(groups_x, trueVel_abs_flipped, 'k--', 'LineWidth', 2);                   

hold on;                                                                      

plot(groups_x, meanVel_abs_flipped, 'rs-', 'LineWidth', 1.5, 'MarkerSize', 6);

xlabel('Group Number');                                                       

ylabel('Velocity (m/s)');                                                     

legend('Actual Velocity','Calculation Velocity','Location','NorthEast');      

title('Actual Velocity vs Random Point Calculation Velocity');                

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

plot(theoryVel, sigmaShort_m*1e3, 'bo-', 'LineWidth', 1.8, 'MarkerSize', 6);   
hold on;                                                                       
plot(theoryVel, sigmaLong_m*1e3,  'rs-', 'LineWidth', 1.8, 'MarkerSize', 6);   
xlabel('Theoretical Velocity (m/s)');                                          
ylabel('Depth Noise Standard Deviation (mm)');                                 
legend('Short Exposure Noise','Long Exposure Noise','Location','NorthWest');   
title('Depth Noise Standard Deviation vs Theoretical Velocity');               
grid on;                                                                       

print(sprintf('%snoise_vs_theoretical_velocity', savePath), '-dpng', '-r300'); 

save(sprintf('%svelocity_analysis.mat', savePath), ...                         
     'trueVel', 'theoryVel', ...                                               
     'actualVelPlot', 'calculationVelPlot', ...                                
     'meanVel', 'meanVelCI', ...                                               
     'rmseVel', 'rmseVelCI', 'maeVel', 'maeVelCI', ...                         
     'meanVelMC', 'rmseVelMC', 'maeVelMC', ...                                 
     'overallRMSE', 'overallMAE', 'r_squared', ...                             
     'overallRMSE_CI', 'overallMAE_CI', 'r_squared_CI', ...                    
     'overallRMSE_MC', 'overallMAE_MC', 'overallR2_MC', ...                    
     'sigmaShort_m', 'sigmaLong_m', 'RsList', ...                              
     'monteCarloTrials', 'rgbTrialIndex', 'confidenceLevel');                  

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


function [sigma_D_short_m, sigma_D_long_m, Rs] = noise(fm_Hz, v_toward_mps, d_start_m, sigma_start_m, T_short_s, T_long_s, Cd) 

if nargin < 1 || isempty(fm_Hz)                                                 
    fm_Hz = 100e6;                                                              
end                                                                             

if nargin < 2 || isempty(v_toward_mps)                                 
    v_toward_mps = 3;                                                  
end                                                                    

if nargin < 3 || isempty(d_start_m)                                    
    d_start_m = 0.9;                                                   
end                                                                    

if nargin < 4 || isempty(sigma_start_m)                                
    sigma_start_m = 6e-3;                                              
end                                                                             

if nargin < 5 || isempty(T_short_s)                                             
    T_short_s = 8e-3;                                                           
end                                                                             

if nargin < 6 || isempty(T_long_s)                                              
    T_long_s = 80e-3;                                                           
end                                                                             

if nargin < 7 || isempty(Cd)                                                    
    Cd = 0.6;                                                                   
end                                                                             

c = 3e8;                                                                        

d_ref_m = 0.9;                                              

if v_toward_mps < 0                                         
    error('v_toward_mps ');         
end                                                         

if d_start_m <= 0                                           
    error('d_start_m');                                     
end                                                         

if d_start_m - v_toward_mps * T_long_s <= 0                 
    error(' 0'); 
end                                                         

if sigma_start_m <= 0                                       
    error('sigma_start_m ');                      
end                                                         

if T_short_s <= 0 || T_long_s <= 0                          
    error('T_short_s T_long_s');              
end                                                         

if T_long_s <= T_short_s                                    
    error('T_long_s  T_short_s。');                   
end                                                         

if Cd <= 0 || Cd > 1                                        
    error('Cd ');                        
end                                                         

phase_to_depth_coeff = c / (4 * pi * fm_Hz);                

G_start_static = T_short_s * (d_ref_m / d_start_m)^2;       

Rs = (phase_to_depth_coeff / (sqrt(2) * Cd * sigma_start_m))^2 / G_start_static; 

d_end_short_m = d_start_m - v_toward_mps * T_short_s;                      

d_end_long_m = d_start_m - v_toward_mps * T_long_s;                        

G_short = d_ref_m^2 / v_toward_mps * (1 / d_end_short_m - 1 / d_start_m);  

G_long = d_ref_m^2 / v_toward_mps * (1 / d_end_long_m - 1 / d_start_m);    

Ns_short = Rs * G_short;                                                   

Ns_long = Rs * G_long;                                                     

sigma_phi_short = 1 / (sqrt(2) * Cd * sqrt(Ns_short));                     

sigma_phi_long = 1 / (sqrt(2) * Cd * sqrt(Ns_long));                       

sigma_D_short_m = phase_to_depth_coeff * sigma_phi_short;                  

sigma_D_long_m = phase_to_depth_coeff * sigma_phi_long;                    


end                                                                        