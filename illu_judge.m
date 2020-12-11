function [is_dark] = illu_judge(params)
%load image
    try
        I = imread(fullfile(params.video_path,'/img/',params.s_frames{1}));
    catch
        try
            I = imread(fullfile(params.s_frames{1}));
        catch
            I = imread(fullfile(params.video_path,params.s_frames{1}));
        end
    end
    Lw=get_illuminance(I);
    [m, n] = size(Lw);%[]æÿ’Û±Ì æ
    % % % log-average luminance
    Lwaver = exp(sum(sum(log(0.001 + Lw))) / (m * n));
    if Lwaver<0.148
        is_dark=1;
    else
        is_dark=0;
    end
end