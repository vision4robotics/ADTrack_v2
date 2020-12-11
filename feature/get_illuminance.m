function Lw=get_illuminance(I)
II = im2double(I);
Ir=double(II(:,:,1)); Ig=double(II(:,:,2)); Ib=double(II(:,:,3));
% Global Adaptation
Lw = 0.299 * Ir + 0.587 * Ig + 0.114 * Ib;% input world luminance values
end