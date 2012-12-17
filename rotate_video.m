% rotate the video (specified by filename)
% for testing purposes
function rotate_video(filename)
    fprintf('---------- Rotating video: %s ----------\n', filename);
    
    % reading
    fprintf('%s\n', 'Reading the video file...');
    vid = VideoReader(filename);
    frame_count = vid.NumberOfFrames - 1;
    fr = vid.FrameRate;
    
    % writing
    fprintf('%s\n', 'Writing the video file...');
    out_vid = VideoWriter('rotated.avi');
    out_vid.FrameRate = fr;
    open(out_vid);
    
    for k = 1:frame_count
        m = permute(read(vid, k), [2 1 3]);
        writeVideo(out_vid, m);
    end
    
    close(out_vid);
    fprintf('%s\n', 'Complete.');
end