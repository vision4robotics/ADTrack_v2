function [xtf,xtf_m,pos,translation_vec,response,disp_row,disp_col] = run_detection(im,pos,sz,target_sz,currentScaleFactor,features,cos_window,g_f,g_f_m,global_feat_params,use_sz,ky,kx,newton_iterations,featureRatio,Vy,Vx,weight,is_dark,ratio)
        center=pos+[Vy Vx];
        pixel_template=get_pixels(im, center, round(sz*currentScaleFactor), sz);  
        [enhanced,m] = SSE(pixel_template,is_dark,round(target_sz/currentScaleFactor),ratio);
        enhanced=im2uint8(enhanced);
        xt=get_features(enhanced,features,global_feat_params);
        usem=mexResize(m,[size(xt,1) size(xt,2)],'auto');
        xt_m=xt.*usem;
        xtf=fft2(bsxfun(@times,xt,cos_window));    
        xtf_m=fft2(bsxfun(@times,xt_m,cos_window)); 
%         savedir='H:\IROS\Ablation\features\';
%         if frame==295
%         xt_f=ifft2(xtf,'symmetric');
%         Xt=sum(xt_f,3);
%         colormap(jet);
%         surf(Xt);
%         shading interp;
%         axis ij;
%         axis off;
%         view([34,50]);
%         saveas(gcf,[savedir,num2str(frame),'.png']);
%         end
%             savedir='H:\IROS\DR2Track\DR2_JOURNAL\Fig1\Featuremaps\';
%             if frame==49
%                 for i=1:42
%             set(gcf,'visible','off'); 
%             colormap(parula);
%             Q=surf(xt(:,:,i));
%             axis ij;
%             axis off;
%             view([0,90]);
%             set(Q,'edgecolor','none');
% %             shading interp
%             saveas(gcf,[savedir,num2str(i),'.png']);
%                 end
%             end
        responsef=permute(sum(bsxfun(@times, conj(g_f), xtf), 3), [1 2 4 3]);
        responsef_m=permute(sum(bsxfun(@times, conj(g_f_m), xtf_m), 3), [1 2 4 3]);
        % if we undersampled features, we want to interpolate the
        % response so it has the same size as the image patch
        useresponse=responsef+weight*responsef_m;
        
        responsef_padded = resizeDFT2(useresponse, use_sz);
        % response in the spatial domain
        response = ifft2(responsef_padded, 'symmetric');
        % find maximum peak
        [disp_row, disp_col] = resp_newton(response, responsef_padded,newton_iterations, ky, kx, use_sz);
        % calculate translation
        translation_vec = round([disp_row, disp_col] * featureRatio * currentScaleFactor);
        %update position
        pos = center + translation_vec;
end

