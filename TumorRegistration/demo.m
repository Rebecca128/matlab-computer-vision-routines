data = open('../../Data/ITV_Workspace.mat')
addpath('../PointCloudGenerator' );
addpath(genpath('../third_party/CPD2/'));
addpath('../plant_registration');
names = data.names_patient002;
segmentation = data.rois_patient002;
num_segmentations = size(segmentation,2);
X_cell = cell(num_segmentations,1);
data = cell(num_segmentations,1);
for i=1:num_segmentations

    b = segmentation{i};
    b_x=[];b_y=[];b_z=[];
    for j = 1:size(b,1)
        b_x = [b_x; b{j}(:,1)];
        b_y = [b_y; b{j}(:,2)];
        b_z = [b_z; b{j}(:,3)];
    end
    
    X_cell{i} = [b_x,b_y,b_z];
    
end
X=X_cell{2};
Y=X_cell{4};

opt.fgt = 2;
opt.method = 'nonrigid_lowrank';
opt.max_iters = 50;
T = cpd_register( X,Y,opt );
Yr_subdiv = T.Y;
[neighbour_id,neighbour_dist] = kNearestNeighbors(X, Yr_subdiv, 1 );
% get nearest neighbour for each point in the original cloud in the
% matched cloud

neighbour_id_u = unique(neighbour_id);

T = cpd_register( Y,X(neighbour_id_u,:) );
X_reg = T.Y;
[neighbour_id_reg,neighbour_dist_reg] = ...
    kNearestNeighbors( X,X_reg, 1 );

                %kNearestNeighbors(Y_reg, X{20}(neighbour_id_u,:), 1 );

sprintf('RMS-E: ' )
rms_e = sqrt( sum(neighbour_dist_reg(:))/ length(neighbour_dist_reg(:)) ) 


%{
iters_rigid = 30;
iters_nonrigid = 20;
lambda = 3;%13; % regularization weight
beta = .1;%10; % width of gaussian
Y = ones(size(X{212}));
[Y(:,1),Y(:,2),Y(:,3),t_r,t_nr,c_r,c_nr] = ...
    registerToReferenceRangeScan(X{20}, X{212}, iters_rigid, ...                                                iters_rigid,...
                                  iters_nonrigid, lambda,...
                                  beta, 1);

% now matched targeted points back onto original scan.                              
idx_unique = unique(c_nr);                         
Xmatched = X{20}(idx_unique,:);
Ymatched = ones(size(X{20}(idx_unique,:)));
[Ymatched(:,1),Ymatched(:,2),Ymatched(:,3),t_r1,t_nr1,c_r1,c_nr1] = ...
    registerToReferenceRangeScan(X{20}, Xmatched, iters_rigid, ...                                                iters_rigid,...
                                  iters_nonrigid, lambda,...
                                  beta, 1);
%OVERLAP RMS-E
% take explicit matches and bring them back
dist_x = X{20}(c_nr1,1) - Ymatched(:,1);
dist_y = X{20}(c_nr1,2) - Ymatched(:,2);
dist_z = X{20}(c_nr1,3) - Ymatched(:,3);
dist = sqrt( dist_x.^2 + dist_y.^2 + dist_z.^2 );
rms = sqrt( sum(dist(:)) / length(dist(:)))
%{                              
lambda = 3;
beta = .1;
Y_ = ones(size(X{212}));
[Y_(:,1),Y_(:,2),Y_(:,3),t_r2,t_nr2,c_r2,c_nr2] = ...
    registerToReferenceRangeScan(X{212},Y, iters_rigid, ...                                                iters_rigid,...
                                  iters_nonrigid, lambda,...
                                  beta, 1);

dist_x  = X{212}(:,1) - Y_(c_nr2,1);
dist_y = X{212}(:,2) - Y_(c_nr2,2);
dist_z = X{212}(:,3) - Y_(c_nr2,3);

dist = sqrt( dist_x.^2 + dist_y.^2 + dist_z.^2 );
rms = sum(dist(:))/sqrt(length(dist))
%}


%{
b = rois_patient001{2};
b_x2=[];b_y2=[];b_z2=[];
for i = 1:size(b,1)
    b_x2 = [b_x2; b{i}(:,1)];
    b_y2 = [b_y2; b{i}(:,2)];
    b_z2 = [b_z2; b{i}(:,3)];
end

%}


Data.vertex.x = b_x;
Data.vertex.y = b_y;
Data.vertex.z = b_z;



%addpath('../file_management/');
%ply_write(Data,'~/Data/tumor.ply' );
%}