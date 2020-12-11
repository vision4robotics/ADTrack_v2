function [ resized_patch ] = get_pixels(im, pos, sz, resize_target)

if isscalar(sz)  %square sub-window
    sz = [sz, sz];
end

%make sure the size is not to small
if sz(1) < 1
    sz(1) = 2;
end
if sz(2) < 1
    sz(2) = 2;
end


xs = floor(pos(2)) + (1:sz(2)) - floor(sz(2)/2);
ys = floor(pos(1)) + (1:sz(1)) - floor(sz(1)/2);

%check for out-of-bounds coordinates, and set them to the values at
%the borders
xs(xs < 1) = 1;
ys(ys < 1) = 1;
xs(xs > size(im,2)) = size(im,2);
ys(ys > size(im,1)) = size(im,1);

%extract image
im_patch = im(ys, xs, :);

if isempty(resize_target)
    resized_patch = im_patch;
else
    resized_patch = mexResize(im_patch,resize_target,'auto');
end
end

