function [currentScaleFactor,base_target_sz,reg_sz,sz,use_sz] = init_size(params,target_sz,search_area)

if search_area > params.image_sample_size
    currentScaleFactor = sqrt(search_area / params.image_sample_size);
elseif search_area <params.image_sample_size
    currentScaleFactor = sqrt(search_area / params.image_sample_size);
else
    currentScaleFactor = 1.0;
end
% target size at the initial scale

featureRatio=params.t_global.cell_size;
base_target_sz = target_sz / currentScaleFactor;
reg_sz= floor(base_target_sz/featureRatio);
% window size, taking padding into account
switch params.search_area_shape
    case 'proportional'
        sz = floor(base_target_sz * params.search_area_scale);     % proportional area, same aspect ratio as the target
    case 'square'
        sz = repmat(sqrt(prod(base_target_sz * params.search_area_scale)), 1, 2); % square area, ignores the target aspect ratio
    case 'fix_padding'
        sz = base_target_sz + sqrt(prod(base_target_sz * params.search_area_scale) + (base_target_sz(1) - base_target_sz(2))/4) - sum(base_target_sz)/2; % const padding
    otherwise
        error('Unknown "params.search_area_shape". Must be ''proportional'', ''square'' or ''fix_padding''');
end

% set the size to exactly match the cell size
sz = round(sz / featureRatio) * featureRatio;
use_sz = floor(sz/featureRatio);

end

