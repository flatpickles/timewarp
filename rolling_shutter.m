% in:          the 4D matrix (height, width, channels, frames) representing
%              original video
% time_offset: the time offset (in ms) between each segmentation of the output
% frame_rate:  video frame rate (fps) 
% crop:        whether to crop the beginning and end of the film, or use
%              the first frame as "background"
% sd:          shutter direction: ±[0 1] or ±[1 0]
%              [vertical horizontal] direction
function out = rolling_shutter(in, time_offset, frame_rate, crop, sd)
    % prettiness
    fprintf('%s\n', 'Building a rolling shutter effect: 0');
    next_percent_print = 0;
    percent_offset = 5;
    
    % determine segmentation relative to offsets
    frames = size(in, 4);
    depth = abs(sd(1) * size(in, 1) + sd(2) * size(in, 2));
    seg_size = max([1 round((1000/frame_rate)/time_offset)]);
    segs = ceil(depth / seg_size);
    
    % malloc appropriately sized output
    if crop
        out(:, :, :, :) = repmat(in(:, :, :, 1), [1 1 1 size(in, 4)]);
    else
        out(:, :, :, :) = repmat(in(:, :, :, 1), [1 1 1 size(in, 4) + segs]);
    end
    
    % find a new output frame for each frame 
    % (exclude first & last two -> no smoothing edge cases)
    for f=2:frames-2
        % percent printout
        dt = round(100 * f/frames);
        if next_percent_print <= dt
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
            % don't leave any space on the end
            this_seg_size = seg_size;
            if s == segs
                this_seg_size = this_seg_size + mod(depth, seg_size);
            end
            % fill in with gaussian time-domain smoothing
            for r=1:this_seg_size
                % calculate mid-frame dt & absolute row/col location
                dt = r/this_seg_size;
                x = (s - 1) * seg_size + r;
                % samples for gaussian blending of four neighboring frames
                [p1 p2 f1 f2 d] = deal(0, 0, 0, 0, 0); % scoping
                if sd(2) == 0
                    d = mod(depth + sd(1) * x, depth);
                    if (d == 0) d = depth; end
                    p1 = in(d, :, :, f);
                    p2 = in(d, :, :, f - 1);
                    f1 = in(d, :, :, f + 1);
                    f2 = in(d, :, :, f + 2);
                else
                    d = mod(depth + sd(2) * x, depth);
                    if (d == 0) d = depth; end
                    p1 = in(:, d, :, f);
                    p2 = in(:, d, :, f - 1);
                    f1 = in(:, d, :, f + 1);
                    f2 = in(:, d, :, f + 2);
                end
                % gaussian weightings
                sig = .75;
                cntr = f + (1 - dt);
                wp1 = gauss(f, sig, cntr);
                wp2 = gauss(f - 1, sig, cntr);
                wf1 = gauss(f + 1, sig, cntr);
                wf2 = gauss(f + 2, sig, cntr);
                % normalize
                weight_sum = wp1 + wp2 + wf1 + wf2;
                wp1 = wp1 / weight_sum;
                wp2 = wp2 / weight_sum;
                wf1 = wf1 / weight_sum;
                wf2 = wf2 / weight_sum;
                % calculate weighted avg
                if sd(2) == 0
                    out(d, :, :, f + s) = (wp2 * p2) + (wp1 * p1) + ...
                        (wf1 * f1) + (wf2 * f2);
                else
                    out(:, d, :, f + s) = (wp2 * p2) + (wp1 * p1) + ...
                        (wf1 * f1) + (wf2 * f2);
                end
            end
        end
    end
    
    % crop front of video if need be
    if crop
        out = out(:, :, :, segs:size(out, 4));
    end
    
    fprintf('\b\b100\n%s\n', 'Rolling shutter done.');
end

% get a gaussian value for weighting...
function o = gauss(x, sig, c)
    o = exp((-(x-c)^2)/(2 * sig^2));
end