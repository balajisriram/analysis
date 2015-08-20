function [binnedRaster] = binRaster(raster,res)
%binRaster takes raster in sparse matrix form and bins it by some
%resolution res.

%raster is sparse matrix returned by getRaster
%resolution is in milliseconds

binSize = 30*res; %30 samples per ms.
rows = size(raster,1);
cols = ceil(size(raster,2)/binSize);

if rows*cols > 1000000000
    error('resolution too small for regular non-sparse matrix');
end

binnedRaster = zeros(rows,cols);

percentComplete = 0;
modNumber = ceil(rows/10);

for i = 1:rows
    if mod(i,modNumber)==1
        disp([num2str(percentComplete), '% Complete']);
        percentComplete=percentComplete+10;
    end
    tempMat = full(raster(i,:));   %grabs row
    if sum(tempMat)>0              %if no 1's in this row do nothing
        for j = 1:cols             %then cycle through columns
            if j == cols  %special case for last column
                for k = ((j-1)*binSize+1):length(tempMat)
                    if tempMat(k) > 0
                        binnedRaster(i,j) = binnedRaster(i,j)+1;
                    end
                end
            else
                for k = ((j-1)*binSize+1):(j*binSize)
                    if tempMat(k) > 0
                        binnedRaster(i,j) = binnedRaster(i,j)+1;
                    end
                end
            end
        end
    end
end

end

