% This function implements the ASRCF tracker.

function [results] = tracker(params)

num_frames     = params.no_fram;
newton_iterations=params.newton_iterations;
global_feat_params = params.t_global;
featureRatio = params.t_global.cell_size;
search_area = prod(params.wsize * params.search_area_scale);
pos         = floor(params.init_pos);
target_sz   = floor(params.wsize);
learning_rate = params.learning_rate;

[currentScaleFactor,base_target_sz,~,sz,use_sz] = init_size(params,target_sz,search_area);
[y,cos_window] = init_gauss_win(params,base_target_sz,featureRatio,use_sz);
yf          = fft2(y);
[features,im,colorImage] = init_features(params);
[ysf,scale_window,scaleFactors,scale_model_sz,min_scale_factor,max_scale_factor] = init_scale(params,target_sz,sz,base_target_sz,im);
% Pre-computes the grid that is used for score optimization
ky = circshift(-floor((use_sz(1) - 1)/2) : ceil((use_sz(1) - 1)/2), [1, -floor((use_sz(1) - 1)/2)]);
kx = circshift(-floor((use_sz(2) - 1)/2) : ceil((use_sz(2) - 1)/2), [1, -floor((use_sz(2) - 1)/2)])';
% initialize the projection matrix (x,y,h,w)
rect_position = zeros(num_frames, 4);
smallsz = floor(base_target_sz/featureRatio);
time = 0;
loop_frame = 1;
Vy=0;
Vx=0;
% avg_list=zeros(num_frames,1);
% avg_list(1)=0;

for frame = 1:num_frames
    im = load_image(params,frame,colorImage);
    tic();  
%% main loop

    if frame > 1
        pos_pre=pos;
        [xtf,xtf_m,pos,translation_vec,response,disp_row,disp_col] = run_detection(im,pos,sz,target_sz,currentScaleFactor,features,cos_window,g_f,g_f_m,global_feat_params,use_sz,ky,kx,newton_iterations,featureRatio,Vy,Vx,params.weight,params.is_dark,params.ratio);
        Vy=pos(1)-pos_pre(1);
        Vx=pos(2)-pos_pre(2);
        % search for the scale of object
        [xs,currentScaleFactor,recovered_scale]  = search_scale(sf_num,sf_den,im,pos,base_target_sz,currentScaleFactor,scaleFactors,scale_window,scale_model_sz,min_scale_factor,max_scale_factor,params);
    end
    % update the target_sz via currentScaleFactor
    target_sz =round(base_target_sz * currentScaleFactor);
    %save position
    rect_position(loop_frame,:) =[pos([2,1]) - (target_sz([2,1]))/2, target_sz([2,1])];
    if frame==1 
            % extract training sample image region
             pixels = get_pixels(im,pos,round(sz*currentScaleFactor),sz);
             pixels = uint8(gather(pixels));
             [enhanced_pixels,mask] = SSE(pixels,params.is_dark,round(target_sz/currentScaleFactor),params.ratio);
             enhanced_pixels=im2uint8(enhanced_pixels);
%              masked_pixels=im2uint8(mask.*enhanced_pixels);
             x=get_features(enhanced_pixels,features,params.t_global);
             usemask=mexResize(mask,[size(x,1) size(x,2)],'auto');
             x_m=x.*usemask;
             xf=fft2(bsxfun(@times,x,cos_window));
             xf_m=fft2(bsxfun(@times,x_m,cos_window));
             model_xf = xf;
             model_xf_m = xf_m;
     else
           % use detection features
            shift_samp_pos = 2*pi * translation_vec ./(currentScaleFactor* sz);
            xf = shift_sample(xtf, shift_samp_pos, kx', ky');
            xf_m = shift_sample(xtf_m, shift_samp_pos, kx', ky');
            model_xf = ((1 - learning_rate) * model_xf) + (learning_rate * xf);
            model_xf_m = ((1 - learning_rate) * model_xf_m) + (learning_rate * xf_m);
    end
     [g_f,g_f_m] = run_training(model_xf,model_xf_m,use_sz,params,yf,smallsz);
            
     
        %% Update Scale
        if frame==1
            xs = crop_scale_sample(im, pos, base_target_sz, currentScaleFactor * scaleFactors, scale_window, scale_model_sz,params.is_dark);
        else
            xs= shift_sample_scale(im, pos, base_target_sz,xs,recovered_scale,currentScaleFactor*scaleFactors,scale_window,scale_model_sz);
        end
        xsf = fft(xs,[],2);
        new_sf_num = bsxfun(@times, ysf, conj(xsf));
        new_sf_den = sum(xsf .* conj(xsf), 1);
        if frame == 1
            sf_den = new_sf_den;
            sf_num = new_sf_num;
        else
            sf_den = (1 - params.learning_rate_scale) * sf_den + params.learning_rate_scale * new_sf_den;
            sf_num = (1 - params.learning_rate_scale) * sf_num + params.learning_rate_scale * new_sf_num;
        end

     time = time + toc();

     %%   visualization
     if params.visualization == 1
        rect_position_vis = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
        figure(1);
        imshow(im);
        if frame == 1
            hold on;
            rectangle('Position',rect_position_vis, 'EdgeColor','g', 'LineWidth',2);
            text(12, 26, ['# Frame : ' int2str(loop_frame) ' / ' int2str(num_frames)], 'color', [1 0 0], 'BackgroundColor', [1 1 1], 'fontsize', 12);
            hold off;
        else
            hold on;
            rectangle('Position',rect_position_vis, 'EdgeColor','g', 'LineWidth',2);
            text(12, 28, ['# Frame : ' int2str(loop_frame) ' / ' int2str(num_frames)], 'color', [1 0 0], 'BackgroundColor', [1 1 1], 'fontsize', 12);
            text(12, 66, ['FPS : ' num2str(1/(time/loop_frame))], 'color', [1 0 0], 'BackgroundColor', [1 1 1], 'fontsize', 12);
            hold off;
         end
        drawnow
    end
    loop_frame = loop_frame + 1;


%   save resutls.
fps = loop_frame / time;
results.type = 'rect';
results.res = rect_position;
results.fps = fps;
end
