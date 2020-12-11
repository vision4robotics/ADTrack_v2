function [out,m] = SSE(I,is_dark,target_sz,ratio)
D = im2double(I);
Ir=single(D(:,:,1)); Ig=single(D(:,:,2)); Ib=single(D(:,:,3));
Lw=get_illuminance(I);
% Lw = im2double(I);
% % % the maximum luminance value
Lwmax = max(max(Lw));
[m, n] = size(Lw);%[]¾ØÕó±íÊ¾
% % % log-average luminance
Lwaver = exp(sum(sum(log(0.001 + Lw))) / (m * n));
Lg = log(Lw / Lwaver + 1) / log(Lwmax / Lwaver + 1);
gain = Lg ./ Lw;
gain(find(Lw == 0)) = 0;
II = cat(3, gain .* Ir, gain .* Ig, gain .* Ib);
delta=get_illuminance(II-D);
if nargin>2
    m=im2single(create_map(delta,target_sz,ratio));
else
    m=zeros(size(delta));
end
if is_dark
    out=II;
else
    out=D;
end
% outval = gain .* Lw;
 
end