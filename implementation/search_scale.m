function [xs,currentScaleFactor,recovered_scale]  = search_scale(sf_num,sf_den,im,pos,base_target_sz,currentScaleFactor,scaleFactors,scale_window,scale_model_sz,min_scale_factor,max_scale_factor,params)
       %%Scale Search
        xs = crop_scale_sample(im, pos, base_target_sz, currentScaleFactor * scaleFactors, scale_window, scale_model_sz,params.is_dark);
        xsf = fft(xs,[],2);
     
            
        scale_response = real(ifft(sum(sf_num .* xsf, 1) ./ (sf_den+params.scale_lambda)));            
        % find the maximum scale response
        recovered_scale = find(scale_response == max(scale_response(:)), 1);
        % update the scale
        currentScaleFactor = currentScaleFactor * scaleFactors(recovered_scale);
        if currentScaleFactor < min_scale_factor
            currentScaleFactor = min_scale_factor;
        elseif currentScaleFactor > max_scale_factor
            currentScaleFactor = max_scale_factor;
       end     

end

