function changed = smartIndentFile(filePath)
%SMARTINDENFILE indents the file and saves as needed.

% Copyright 2026 The MathWorks, Inc.

    original = fileread(filePath);
    indented = indentcode(original);
    changed = ~strcmp(original, indented);
    if changed
        writelines(indented, filePath);
    end
end


