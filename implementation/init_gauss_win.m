function [y0,cos_window] = init_gauss_win(params,base_target_sz,featureRatio,use_sz)
% construct the label function- correlation output, 2D gaussian function,
% with a peak located upon the target

output_sigma = sqrt(prod(floor(base_target_sz/featureRatio))) * params.output_sigma_factor;
rg           = circshift(-floor((use_sz(1)-1)/2):ceil((use_sz(1)-1)/2), [0 -floor((use_sz(1)-1)/2)]);
cg           = circshift(-floor((use_sz(2)-1)/2):ceil((use_sz(2)-1)/2), [0 -floor((use_sz(2)-1)/2)]);
[rs, cs]     = ndgrid(rg,cg);
y0           = exp(-0.5 * (((rs.^2 + cs.^2) / output_sigma^2)));
% construct cosine window
cos_window = single(hann(use_sz(1)+2)*hann(use_sz(2)+2)');
cos_window = cos_window(2:end-1,2:end-1);
end

