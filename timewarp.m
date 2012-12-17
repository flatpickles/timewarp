function timewarp(filename)
    fprintf('---------- Video file: %s ----------\n', filename);

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
    out_vid.FrameRate = fr * 2; % speed it up for testing
    open(out_vid);
    
    % find motion metric to determine ms_offset
    mm = motion_metric(in, fr)
    % TODO: use to find ms_offset; more motion -> less offset
    
    % do some stuff to the frames here!!
    ms_offset = 15; 
    out = rolling_shutter(in, ms_offset, fr, false, [1 0]);
    
    % write the video back out
    fprintf('%s\n', 'Building the output file...');
    for k = 1:size(out, 4)
        writeVideo(out_vid, round(out(:, :, :, k))/255.0);
    end
    
    % close 'er down
    close(out_vid);
    
    fprintf('%s\n', 'Complete.');
end