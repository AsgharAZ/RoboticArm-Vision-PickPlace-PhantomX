function coords = get_cubes_locs()
    %% Create all objects to be used in this file
    % Make Pipeline object to manage streaming
    pipe = realsense.pipeline();
    % Make Colorizer object to prettify depth output
    colorizer = realsense.colorizer();
    % Create a config object to specify configuration of pipeline
    cfg = realsense.config();
    
    %% Set configuration and start streaming with configuration
    % Stream options are in stream.m
    streamType = realsense.stream('depth');
    % Format options are in format.m
    formatType = realsense.format('Distance');
    % Enable default depth
    cfg.enable_stream(streamType, formatType);
    % Enable color stream
    streamType = realsense.stream('color');
    formatType = realsense.format('rgb8');
    cfg.enable_stream(streamType, formatType);
    % Start streaming on an arbitrary camera with chosen settings
    profile = pipe.start();
    
    %% Acquire and Set device parameters
    % Get streaming device's name
    dev = profile.get_device();
    name = dev.get_info(realsense.camera_info.name);
    % Access Depth Sensor
    depth_sensor = dev.first('depth_sensor');
    % Access RGB Sensor
    rgb_sensor = dev.first('roi_sensor');
    % Find the mapping from 1 depth unit to meters
    depth_scaling = depth_sensor.get_depth_scale();
    % Set the control parameters for the depth sensor
    depth_sensor.set_option(realsense.option('visual_preset'), 9);
    % Set autoexposure for RGB sensor
    rgb_sensor.set_option(realsense.option('enable_auto_exposure'), 1);
    rgb_sensor.set_option(realsense.option('enable_auto_white_balance'), 1);
    
    %% Align the color frame to the depth frame and then get the frames
    % Get frames. We discard the first couple to allow
    % the camera time to settle
    for i = 1:5
        fs = pipe.wait_for_frames();
    end
    % Alignment
    align_to_depth = realsense.align(realsense.stream.depth);
    fs = align_to_depth.process(fs);
    % Stop streaming
    pipe.stop();
    
    %% Depth Post-processing
    % Select depth frame
    depth = fs.get_depth_frame();
    width = depth.get_width();
    height = depth.get_height();
    % Spatial Filtering
    spatial = realsense.spatial_filter(.5, 20, 2);
    depth_p = spatial.process(depth);
    % Temporal Filtering
    temporal = realsense.temporal_filter(.13, 20, 3);
    depth_p = temporal.process(depth_p);
    
    %% Color Post-processing
    % Select color frame
    color = fs.get_color_frame();
    
    %% Colorize and display depth frame
    % Colorize depth frame
    depth_color = colorizer.colorize(depth_p);
    data = depth_color.get_data();
    img = permute(reshape(data',[3, depth_color.get_width(), depth_color.get_height()]), [3 2 1]);
    % Display image
    imshow(img);
    
    %% Depth frame without colorizing
    data3 = depth_scaling * single(depth_p.get_data());
    ig = permute(reshape(data3',[width, height]), [2 1]);
    % Scale depth values to [0 1] for display
    imshow(mat2gray(ig));
    
    %% Display RGB frame
    data2 = color.get_data();
    im = permute(reshape(data2',[3, color.get_width(), color.get_height()]), [3 2 1]);
    % Display image
    imshowpair(im, BW, 'montage');
    
    %% Processing for cube identification and extraction
    tmp_img = ~(BW(:,:,1) & BW(:,:,2) & BW(:,:,3));
    cc4 = bwconncomp(tmp_img, 4);
    for k = 1:cc4.NumObjects
        siz_ = size(cc4.PixelIdxList{k});
        if siz_(1) < 500 || siz_(1) > 800
            tmp_img(cc4.PixelIdxList{k}) = 0;
        end
    end
    cc4_ = bwconncomp(tmp_img, 4);
    red_col = zeros(1, cc4_.NumObjects);
    green_col = zeros(1, cc4_.NumObjects);
    blue_col = zeros(1, cc4_.NumObjects);
    red_im = im(:,:,1);
    green_im = im(:,:,2);
    blue_im = im(:,:,3);
    for k = 1:cc4_.NumObjects
        mean_red_pix = mean(red_im(cc4_.PixelIdxList{k}));
        mean_green_pix = mean(green_im(cc4_.PixelIdxList{k}));
        mean_blue_pix = mean(blue_im(cc4_.PixelIdxList{k}));
        if mean_red_pix > 65
            red_col(k) = 1;
        end
        if mean_green_pix > 65
            green_col(k) = 1;
        end
        if mean_blue_pix > 67
            blue_col(k) = 1;
        end
    end
    % Top face detection and centroid calculation
    cc4_for_cen = bwconncomp(blank_img);
    coords_centroids = zeros(2, cc4_for_cen.NumObjects);
    for i = 1:cc4_for_cen.NumObjects
        col_ = mod(cc4_for_cen.PixelIdxList{i}, 480);
        row_ = ceil(cc4_for_cen.PixelIdxList{i}/480);
        row_fin = ceil(mean(row_));
        col_fin = ceil(mean(col_));
        coords_centroids([1,2],i) = [row_fin, col_fin];
        blank_img(row_fin, col_fin) = 0;
    end
    
    %% Calculate real-world coordinates
    X = 292;
    Y = 238;
    len = size(coords_centroids);
    for k = 1:len(2)
        coords_centroids(1,k) = coords_centroids(1,k) - X;
        coords_centroids(2,k) = coords_centroids(2,k) - Y;
    end
    coords_centroids
    coords_ = [];
    tmp = coords_centroids';
    for k = 1:len(2)
        coords_{k} = [coords_centroids(1,k), coords_centroids(2,k), z_val(k)*10];
    end
    coords = coords_';
end