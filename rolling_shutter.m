% in:          the 4D matrix (height, width, channels, frames) representing
%              original video
% time_offset: the time offset (in ms) between each segmentation of the output
% frame_rate:  video frame rate (fps) 
function out = rolling_shutter(in, time_offset, frame_rate)
    fprintf('%s\n', 'Building a rolling shutter effect: 0');
    out(:, :, :, :) = repmat(in(:, :, :, 1), [1 1 1 size(in, 4)]);
    
    frames = size(in, 4);
    h = size(in, 1);
    
    next_percent_print = 0;
    percent_offset = 1;
    
    % find a new output frame for each frame
    for f=1:frames
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
        seg_height = round((1000/frame_rate)/time_offset);
        segs = ceil(h / seg_height);
        for s=1:segs
            if f+s > h
                % don't go OOB
                break
            end
            out(((s - 1) * seg_height + 1):min([(s * seg_height) h]), :, :, f+s) = ...
                in(((s - 1) * seg_height + 1):min([(s * seg_height) h]), :, :, f);
        end
        
    end
    fprintf('\n%s\n', 'Rolling shutter done.');
end