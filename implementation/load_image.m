function im = load_image(params,frame,colorImage)
%load image
    try
        im = imread([params.video_path '/img/' params.s_frames{frame}]);
    catch
        try
            im = imread([params.s_frames{frame}]);
        catch
            im = imread([params.video_path '/' params.s_frames{frame}]);
        end
    end
    if size(im,3) > 1 && colorImage == false
        im = im(:,:,1);
    end
end

