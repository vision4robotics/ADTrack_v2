function [gtt,rd_update,redetection] = extract_template(im,pos,target_sz,sz,features,global_feat_params,redetection)
        gt_pixel=get_pixels(im, pos, target_sz, sz);             
        gtt=get_features(gt_pixel,features,global_feat_params);
        if redetection
             redetection=0;
        end
        rd_update=1;
end

