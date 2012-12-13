% in:          the 4D matrix (height, width, channels, frames) representing
%              original video
% time_offset: the time offset (in ms) between each segmentation of the output
% frame_rate:  video frame rate (fps) 
function out = rolling_shutter(in, time_offset, frame_rate, crop)
    % prettiness
    fprintf('%s\n', 'Building a rolling shutter effect: 0');
    next_percent_print = 0;
    percent_offset = 5;
    
    % determine segmentation relative to offsets
    frames = size(in, 4);
    h = size(in, 1);
    seg_height = max([1 round((1000/frame_rate)/time_offset)]);
    segs = ceil(h / seg_height);
    
    % malloc appropriately sized output
    if crop
        out(:, :, :, :) = repmat(in(:, :, :, 1), [1 1 1 size(in, 4)]);
    else
        out(:, :, :, :) = repmat(in(:, :, :, 1), [1 1 1 size(in, 4) + segs]);
    end
    
    % find a new output frame for each frame
    for f=1:frames-1
        % percent printout
        p = round(100 * f/frames);
        if next_percent_print <= p
            fprintf('\b');
            if next_percent_print > 9
                fprintf('\b')
            end
            fprintf('%d', next_percent_print);
            next_percent_print = next_percent_print + percent_offset;
        end
        
        % cascade through future frames
        for s=1:segs
            % don't overflow
            if f + s > frames && crop
                break
            end
            % don't leave any space on the bottom
            this_seg_height = seg_height;
            if s == segs
                this_seg_height = this_seg_height + mod(h, seg_height);
            end
            % fill in with linear time-domain smoothing
            for r=1:this_seg_height
                p = r/this_seg_height; % linear blend, bottom to top
                x = (s - 1) * seg_height + r; % row location
                out(x,:,:, f+s) = (1 - p) * in(x, :, :, f + 1) + p * in(x, :, :, f);
            end
        end
    end
    
    % crop front of video if need be
    if crop
        out = out(:, :, :, segs:size(out, 4));
    end
    
    fprintf('\n%s\n', 'Rolling shutter done.');
end