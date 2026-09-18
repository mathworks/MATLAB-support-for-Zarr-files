function changed = smartIndentFile(filePath)
    original = fileread(filePath);
    indented = indentcode(original);
    changed = ~strcmp(original, indented);
    if changed
        fid = fopen(filePath, "w");
        fwrite(fid, indented);
        fclose(fid);
    end
end
