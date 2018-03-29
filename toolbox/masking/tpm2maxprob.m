function tpm2maxprob(varargin)
%tpm2maxprob: Binarise Tissue Probability Maps according to max probability
%
% Usage:
%  tpm2maxprob(probmaps)          % character array of maps or of 4D NIfTI
%  tpm2maxprob(maps1, maps2, ...) % separate lists of one or more subjects
%
% Note that for each subject maps1 is compared to maps2 (etc.)
%
% Examples:
%
%  tpm2maxprob('c1blah.nii', 'c2blah.nii', 'c3blah.nii') % single subject
%
%  c1s = spm_select('List', pwd, '^c1.*\.nii') % select GM segmentations
%  c2s = spm_select('List', pwd, '^c2.*\.nii') % select WM segmentations
%  c3s = spm_select('List', pwd, '^c3.*\.nii') % select CSF segmentations
%  tpm2maxprob(c1s, c2s, c3s)                  % process each subject
%
%  tpm2maxprob('Dartel_Template.nii') % process each 3D volume from a 4D
%  % template constructed using Dartel on e.g. GM and WM segmentations.
%
%
% Output images are suffixed with '_mx' before the extension, e.g.
% c1blah_mx.nii is the binary version of c1blah.nii for the first example.
%
% See also: opt_thresh
%
% Copyright 2009 Ged Ridgway

if nargin > 1 % assume separate lists of tissues for one or more subjects
    N = size(varargin{1}, 1); % number of subjects
    names = cellstr(varargin{1}); % accumulate others below
    for v = 2:nargin
        if size(varargin{v}, 1) ~= N
            error('Incompatible numbers of scans')
        end
        names = cat(2, names, cellstr(varargin{v}));
    end
    % now pass each set one at a time (with nargin==1, so rest of function)
    for n = 1:N
        tpm2maxprob(char(names(n, :)));
    end
    return
elseif nargin == 1
    tpm = varargin{1};
else
    tpm = '';
end


if ~exist('tpm', 'var') || isempty(tpm)
    tpm = spm_select(inf, 'nifti');
end

if size(tpm, 1) > 1 % assume multiple volumes, e.g. gray, white, csf
    V = spm_vol(tpm);
    D = spm_read_vols(V);
    M = maxprob(D);
    out = V;
    for l = 1:numel(V)
        [pth fnm ext] = spm_fileparts(out(l).fname);
        out(l).fname = fullfile(pth, [fnm '_mx' ext]);
        % Note: number preserved in out.n if volumes selected from 4D nifti
        out(l).dt(1) = spm_type('uint8');
        out(l).pinfo = [1 0 0]';
        spm_write_vol(out(l), M(:, :, :, l));
    end
else % assume single multiple-volume nifti, as in SPM8's new seg toolbox
    N = nifti(tpm);
    D = N.dat(:, :, :, :);
    M = maxprob(D);
    out = N;
    [pth fnm ext] = spm_fileparts(out.dat.fname);
    out.dat.fname = fullfile(pth, [fnm '_mx' ext]);
    out.dat.dtype = spm_type('uint8');
    out.dat.scl_slope = 1;
    out.dat.scl_inter = 0;
    create(out);
    out.dat(:, :, :, :) = M;
end


function M = maxprob(D)
dim = size(D); % before potentially adding "other" class below
tot = sum(D, 4);
if max(tot(:)) > 257/255 % (conservative 1+eps for potentially uint8 data)
    warning('maxprob:norming', ...
        'Sum of probability maps is above 1, normalising by sum...')
    tot(tot < eps) = 1; % leave alone any "background" voxels
    for d = 1:dim(4)
        D(:, :, :, d) = D(:, :, :, d) ./ tot;
    end
end
% assume "other" accounts for any remaining probability (okay if it's zero)
D(:, :, :, end+1) = 1 - tot;
[val L] = max(D, [], 4); %#ok max val unused
M = zeros(dim);
for l = 1:dim(4) % don't put "other" into M
    M(:, :, :, l) = double(L == l);
end
