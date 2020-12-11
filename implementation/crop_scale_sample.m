function out = crop_scale_sample(im, pos, base_target_sz, scaleFactors, scale_window, scale_model_sz,is_dark)
 
% Extracts a sample for the scale filter at the current
% location and scale.

nScales = length(scaleFactors);
max_sz= floor(base_target_sz * max(scaleFactors));
xs_max = floor(pos(2)) + (1:max_sz(2)) - floor(max_sz(2)/2);
ys_max = floor(pos(1)) + (1:max_sz(1)) - floor(max_sz(1)/2);

% check for out-of-bounds coordinates, and set them to the values at
% the borders
xs_max(xs_max < 1) = 1;
ys_max(ys_max < 1) = 1;
xs_max(xs_max > size(im,2)) = size(im,2);
ys_max(ys_max > size(im,1)) = size(im,1);

if max(xs_max)==min(xs_max) || max(ys_max)==min(ys_max)
    a=floor(scale_model_sz(1)/4);
    b=floor(scale_model_sz(2)/4);
    out = zeros(a*b*31, nScales, 'single');
else

    % extract image
    [base_im_patch,~] = SSE(im(ys_max, xs_max, :),is_dark);

    base_im_patch = im2uint8(base_im_patch);

    new_pos=[floor(size(base_im_patch,1)/2) floor(size(base_im_patch,2)/2)];

    for s = 1:nScales
        patch_sz = floor(base_target_sz * scaleFactors(s));

        xs = floor(new_pos(2)) + (1:patch_sz(2)) - floor(patch_sz(2)/2);
        ys = floor(new_pos(1)) + (1:patch_sz(1)) - floor(patch_sz(1)/2);

        % check for out-of-bounds coordinates, and set them to the values at
        % the borders
        xs(xs < 1) = 1;
        ys(ys < 1) = 1;
        xs(xs > size(base_im_patch,2)) = size(base_im_patch,2);
        ys(ys > size(base_im_patch,1)) = size(base_im_patch,1);

        % extract image
        im_patch = base_im_patch(ys,xs,:);

        % resize image to model size
        im_patch_resized = mexResize(im_patch, scale_model_sz, 'auto');

        % extract scale features
        temp_hog = fhog(single(im_patch_resized), 4);
        temp = temp_hog(:,:,1:31);

        if s == 1
            out = zeros(numel(temp), nScales, 'single');
        end

        % window
        out(:,s) = temp(:) * scale_window(s);
    end
end