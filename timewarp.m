function timewarp(filename, varargin)
    fprintf('---------- Video file: %s ----------\n', filename);
    ms_offset = -1;
    if size(varargin) ~= 0
        ms_offset = str2num(varargin{1});
    end

    % reading
    fprintf('%s\n', 'Reading the video file...');
    vid = VideoReader(filename);
    frame_count = vid.NumberOfFrames - 1;
    h = vid.Height;
    w = vid.Width;
    fr = vid.FrameRate;
    
    % storing
    in = zeros(h, w, 3, frame_count);
    for k = 1:frame_count
        in(:, :, :, k) = read(vid, k);
    end
    
    % writing
    out_vid = VideoWriter('out.avi');
    out_vid.FrameRate = fr * 1; % speed it up for testing
    open(out_vid);
    
%     % find motion metric to determine ms_offset (experimental)
%     mm = motion_metric(in, fr)
%     ms_offset = max([round(1 / (3.5 * mm)) - 5 1])
%     fprintf('%d%s', ms_offset, ' ms might be a good offset. Press enter, or ');
%     t = input('input a different offset: ');
%     if (t) ms_offset = t; end
    
    if ms_offset == -1
        ms_offset = input(strcat(strcat('Input millisecond offset for each pixel row/col.\n', ...
            'Good values range [0 2] * framerate - less offset for videos w/ more motion\n', ...
            'Offset:  ')));
    end
    
    % do some stuff
    out = rolling_shutter(in, ms_offset, fr, false, [-1 0]);
    
    % write the video back out
    fprintf('%s\n', 'Building the output file...');
    for k = 1:size(out, 4)
        writeVideo(out_vid, round(out(:, :, :, k))/255.0);
    end
    
    % close 'er down
    close(out_vid);
    
    fprintf('%s\n', 'Complete.');
end