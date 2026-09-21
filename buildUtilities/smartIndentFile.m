function changed = smartIndentFile(filePath)
    original = fileread(filePath);
    indented = indentcode(original);
    changed = ~strcmp(original, indented);
    if changed
        writelines(indented, filePath);
    end
end
