% Function to get a metric associated with overall motion in film
% mov:       4D video matrix
% framerate: fps of mov
function metric = motion_metric(mov, framerate)
    % constants
    scalefactor = .05;
    metric = 0;
    last_frame = -1;
    
    % iterate through all frame differences, looking at bicubic subsampling
    for f=1:size(mov, 4)
        frame = imresize(mov(:, :, :, f), scalefactor);
        % calculate ssd, add to metric
        if last_frame ~= -1
            metric = metric + sum(sum(sum((frame - last_frame) .^ 2)));
        end
        last_frame = frame;
    end
    
    % framerate has exponential relationship (via ssd)
    % number of frames has linear relationship
    metric = (metric / framerate ^ 2) / size(mov, 4);
end