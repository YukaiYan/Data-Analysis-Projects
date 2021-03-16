% wavelet transform
function dData = d_wavelet(dfile)
    
    [m,~, n] = size(dfile);  % 28*28*n
    nw = m^2/4;              % wavelet resolution
    dData = zeros(nw,n);
    
    for k = 1:n
        X = im2double(dfile(:,:,k));
        [~,cH,cV,~] = dwt2(X,'haar');
        cod_cH1 = rescale(abs(cH));
        cod_cV1 = rescale(abs(cV));
        cod_edge = cod_cH1 + cod_cV1;
        dData(:,k) = reshape(cod_edge,nw,1); 
    end
end