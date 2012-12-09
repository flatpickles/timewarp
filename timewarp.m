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
    open(out_vid);
    
    % do some stuff to the frames here!!
    ms_offset = 10; 
    out = rolling_shutter(in, ms_offset, fr);
    
    % write the video back out
    fprintf('%s\n', 'Building the output file...');
    for k = 1:frame_count
        writeVideo(out_vid, out(:, :, :, k)/255.0);
    end
    
    % close 'er down
    close(out_vid);
    
    fprintf('%s\n', 'Complete.');
end


%%%%%% IDEAS %%%%%%
% rolling shutter
% - top to bottom
% - mirrored across center
% - along a diagonal
% - along a vector in the direction of motion (average movement of
%       keypoints between frames
% adjust brightness by speed of motion in the frame (average distance
%   between keypoints