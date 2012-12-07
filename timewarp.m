function timewarp(filename)
    % reader
    vid = VideoReader(filename);

    % writer
    out_vid = VideoWriter('out.avi');
    open(out_vid);

    % write one frame at a time.
    for k = 1 : 100
        writeVideo(out_vid, read(vid, k));
    end

    % close 'er down
    close(out_vid);
end