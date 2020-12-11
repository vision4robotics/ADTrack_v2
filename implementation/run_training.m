function [g_f,g_f_m] = run_training(model_xf,model_xf_m,use_sz,params,yf,small_filter_sz)
        g_f = single(zeros(size(model_xf)));
        g_f_m=g_f;
        h_f = g_f;
        h_f_m=g_f;
        l_f = h_f;
        l_f_m=g_f;
        mu = params.admm_mu;
        mu_m=params.admm_mu_m;
        eta=params.eta;
        betha = 10;
        mumax = 10000;
        % ADMM solution    
        T = prod(use_sz);
        S_xx = sum(conj(model_xf) .* model_xf, 3);
        S_xx_m = sum(conj(model_xf_m) .* model_xf_m, 3);
        i=1;
        j=1;
        while (i <= params.admm_iterations1)
            %solve for G
            B = S_xx + (T * mu);
            S_lx = sum(conj(model_xf) .* l_f, 3);
            S_hx = sum(conj(model_xf) .* h_f, 3);
            g_f = (((1/(T*mu)) * bsxfun(@times, yf, model_xf)) - ((1/mu) * l_f) + h_f) - ...
                bsxfun(@rdivide,(((1/(T*mu)) * bsxfun(@times, model_xf, (S_xx .* yf))) - ((1/mu) * bsxfun(@times, model_xf, S_lx)) + (bsxfun(@times, model_xf, S_hx))), B);

            %   solve for H
            h = (T/((mu*T)+eta+ params.admm_lambda1))* ifft2((mu*g_f) + l_f+(eta/T)*h_f_m);
            [sx,sy,h] = get_subwindow_no_window(h, floor(use_sz/2) , small_filter_sz);
            t = zeros(use_sz(1), use_sz(2), size(h,3));
            t(sx,sy,:) = h;
            h_f = fft2(t);



            %   update L
            l_f = l_f + (mu * (g_f - h_f));
            %   update mu- betha = 10.
            mu = min(betha * mu, mumax);
            i = i+1;
            while (j<= params.admm_iterations2)
                %solve for G_m
                B_m = S_xx_m + (T * mu_m);
                S_lx_m = sum(conj(model_xf_m) .* l_f_m, 3);
                S_hx_m = sum(conj(model_xf_m) .* h_f_m, 3);
                g_f_m = (((1/(T*mu_m)) * bsxfun(@times, yf, model_xf_m)) - ((1/mu_m) * l_f_m) + h_f_m) - ...
                bsxfun(@rdivide,(((1/(T*mu_m)) * bsxfun(@times, model_xf_m, (S_xx_m .* yf))) - ((1/mu_m) * bsxfun(@times, model_xf_m, S_lx_m)) + (bsxfun(@times, model_xf_m, S_hx_m))), B_m);

                %solve for H_m
                h_m = (T/((mu_m*T)+eta+ params.admm_lambda2))* ifft2((mu_m*g_f_m) + l_f_m+(eta/T)*h_f);
                [sx_m,sy_m,h_m] = get_subwindow_no_window(h_m, floor(use_sz/2) , small_filter_sz);
                t_m = zeros(use_sz(1), use_sz(2), size(h,3));
                t_m(sx_m,sy_m,:) = h_m;
                h_f_m = fft2(t_m);

                %update L_m
                l_f_m = l_f_m + (mu * (g_f_m - h_f_m));
                %   update mu- betha = 10.
                mu_m = min(betha * mu_m, mumax);
                j = j+1;
            end
        end
end

