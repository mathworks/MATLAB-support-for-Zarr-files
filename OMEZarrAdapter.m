classdef OMEZarrAdapter < images.blocked.Adapter
    % OMEZarrAdapter A blockedImage adapter for Zarr files with OME data.
    %  adapter = OMEZarrAdapter() creates a blockedImage adapter for use with
    %  the blockedImage object. This adapter uses the "MATLAB support for
    %  Zarr files" project to represent an OME formatted Zarr source as a
    %  blockedImage object in MATLAB.
    %
    %  Supported Name-Value pairs:
    %    PermuteOrder  1xN array of integer indices specifying the data
    %                  dimension permutation order. Defaults to N:-1:1
    %                  where N is the data dimensionality. Useful when raw
    %                  data does NOT adher to tczyx order.
    %
    % Example:
    %  % Sample data downloaded from https://ome.github.io/ome-ngff-tools/
    %  zfile = "/data/work/zarr/9846318.zarr/0";
    %  bim = blockedImage(zfile, Adapter=OMEZarrAdapter)
    %  bim.Size
    %  imageshow(bim)

    %   Copyright 2025 The MathWorks, Inc.

    properties (Access = private)
        ZarrRootPath (1,1) string
        Info (1,1) struct
    end

    properties(SetAccess=private)
        PermuteOrder double = [];
    end

    methods

        function obj = OMEZarrAdapter(options)
            arguments                
                options.PermuteOrder double = [];
            end
            obj.PermuteOrder = options.PermuteOrder;
        end

        function openToRead(obj, zpath)
            obj.ZarrRootPath = zpath;
        end

        function info = getInfo(obj)
            zinfo = zarrinfo(obj.ZarrRootPath);

            assert(~isfield(zinfo,'plate'),"Plate format is not yet supported");

            obj.Info.UserData.RootInfo = zinfo;

            if ~isfield(zinfo,"multiscales")
                error("OMEZarrAdapter:notMultiscale",...
                    obj.ZarrRootPath+" does not have multiscale data.");
            end

            % TODO - Inspect and use "order" property (C (row major) or F (col major, rare)).

            for lvlInd = 1:numel(zinfo.multiscales.datasets)
                dzinfo = zarrinfo(obj.ZarrRootPath+"/"+zinfo.multiscales.datasets(lvlInd).path);
                obj.Info.UserData.DataSetInfo(lvlInd) = dzinfo;
                obj.Info.Size(lvlInd,:)         = dzinfo.shape';
                obj.Info.IOBlockSize(lvlInd,:)  = dzinfo.chunks';
                obj.Info.Datatype(lvlInd,:)     = string(z2mtype(dzinfo.dtype));
            end
            obj.Info.InitialValue = zeros(1,1,obj.Info.Datatype(1));

            obj.Info.Size = obj.Info.Size(:,obj.PermuteOrder);
            obj.Info.IOBlockSize = obj.Info.IOBlockSize(:,obj.PermuteOrder);

            try
                for aInd = 1:numel(zinfo.multiscales.axes)
                    obj.Info.UserData.Dimensions(aInd).Name = string(zinfo.multiscales.axes(aInd).name);
                    obj.Info.UserData.Dimensions(aInd).Type = string(zinfo.multiscales.axes(aInd).type);
                    if isfield(zinfo.multiscales.axes(aInd),'unit')
                        obj.Info.UserData.Dimensions(aInd).Unit = string(zinfo.multiscales.axes(aInd).unit);
                    else
                        obj.Info.UserData.Dimensions(aInd).Unit = "none";
                    end
                end
                obj.Info.UserData.Dimensions = struct2table(obj.Info.UserData.Dimensions);                
            catch ME
                % TODO - some files dont have this property, is that
                % allowed?
                % warning("OMEZarrAdapter:noAxes","No Axes information in multiscales property");
            end


            % TODO - Make the default look at the existing order and figure
            % out the permutation to make it xyzct instead of just
            % flipping. (Note: Most files seem to be tczyx order, so below
            % ought to work just the same). Some files do not have this
            % axes information.
            if isempty(obj.PermuteOrder)
                obj.PermuteOrder = fliplr(1:numel(dzinfo.shape));
            end
            if isfield(obj.Info.UserData,'Dimensions')
                obj.Info.UserData.Dimensions = obj.Info.UserData.Dimensions(obj.PermuteOrder,:);
            end

            % TODO - potentially update IOBlockSize for channels to expand
            % to 3 for RGB images (helps combine 3 getIOBlock calls to
            % one).

            info = obj.Info;
        end

        function data = getIOBlock(obj, ioblocksub, level)
            zpath = obj.ZarrRootPath+"/"+obj.Info.UserData.RootInfo.multiscales.datasets(level).path;
            start = (ioblocksub - 1) .* obj.Info.IOBlockSize(level,:) + 1;
            count = obj.Info.IOBlockSize(level,:);

            start = start(obj.PermuteOrder);
            count = count(obj.PermuteOrder);
            data = zarrread(zpath,'Start',start,'Count',count);

            % TODO - squeeze removes all singleton dimensions, could result
            % in a bug in the rare case of partial (1 element wide) blocks.
            data = squeeze(permute(data,obj.PermuteOrder));
        end

        function data = getFullImage(obj, level)
            zpath = obj.ZarrRootPath+"/"+obj.Info.UserData.RootInfo.multiscales.datasets(level).path;
            data = zarrread(zpath);
            data = squeeze(permute(data,obj.PermuteOrder));
        end

    end
end


% !LLM generated
function mtype = z2mtype(ztype)
% Z2MTYPE Converts a Zarr data type string to a MATLAB data type string.
%
%   mtype = Z2MTYPE(ztype)
%
%   Inputs:
%     ztype - A string representing the Zarr data type (e.g., '<u2', 'f4', 'b1').
%
%   Outputs:
%     mtype - A string representing the corresponding MATLAB data type
%             (e.g., 'uint16', 'single', 'logical').

% Remove endianness or byte order indicator for mapping
if startsWith(ztype, '<') || startsWith(ztype, '>') || startsWith(ztype, '|')
    ztype_clean = ztype(2:end);
else
    ztype_clean = ztype;
end

% Handle common Zarr data types
switch lower(ztype_clean)
    case 'b1'
        mtype = 'logical';
    case {'i1'}
        mtype = 'int8';
    case {'u1'}
        mtype = 'uint8';
    case {'i2'}
        mtype = 'int16';
    case {'u2'}
        mtype = 'uint16';
    case {'i4'}
        mtype = 'int32';
    case {'u4'}
        mtype = 'uint32';
    case {'i8'}
        mtype = 'int64';
    case {'u8'}
        mtype = 'uint64';
    case {'f4'}
        mtype = 'single';
    case {'f8'}
        mtype = 'double';
    otherwise
        % Unknown Zarr type
        error('OMEZarrAdapter:UnknownDataType', 'Unknown Zarr data type: %s. Returning empty string.', ztype);
end

end
