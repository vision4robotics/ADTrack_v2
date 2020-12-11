function [ysf,scale_window,scaleFactors,scale_model_sz,min_scale_factor,max_scale_factor] = init_scale(params,target_sz,sz,base_target_sz,im)
%% SCALE ADAPTATION INITIALIZATION
% Use the translation filter to estimate the scale
scale_sigma = sqrt(params.num_scales) * params.scale_sigma_factor;
ss = (1:params.num_scales) - ceil(params.num_scales/2);
ys = exp(-0.5 * (ss.^2) / scale_sigma^2);
ysf = single(fft(ys));
if mod(params.num_scales,2) == 0
    scale_window = single(hann(params.num_scales+1));
    scale_window = scale_window(2:end);
else
    scale_window = single(hann(params.num_scales));
end
ss = 1:params.num_scales;
scaleFactors = params.scale_step.^(ceil(params.num_scales/2) - ss);
if params.scale_model_factor^2 * prod(target_sz) > params.scale_model_max_area
    params.scale_model_factor = sqrt(params.scale_model_max_area/prod(target_sz));
end
if prod(target_sz) >params.scale_model_max_area
    params.scale_model_factor = sqrt(params.scale_model_max_area/prod(target_sz));
end
scale_model_sz = floor(target_sz * params.scale_model_factor);
scale_model_sz=max(scale_model_sz,2);
% set maximum and minimum scales
min_scale_factor = params.scale_step ^ ceil(log(max(5 ./sz)) / log(params.scale_step));
max_scale_factor =params.scale_step ^ floor(log(min([size(im,1) size(im,2)] ./ base_target_sz)) / log(params.scale_step));
    
end

