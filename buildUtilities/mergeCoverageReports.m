function summary = mergeCoverageReports(artifactsDir, outputMarkdown)
%MERGECOVERAGEREPORTS Merge Cobertura XML coverage reports into a Markdown summary.
%   SUMMARY = MERGECOVERAGEREPORTS(ARTIFACTSDIR, OUTPUTMARKDOWN) searches
%   ARTIFACTSDIR recursively for cobertura.xml files, merges line hits
%   across all reports (taking the max hit count per line per file), writes
%   a Markdown summary to OUTPUTMARKDOWN, and returns it as a string.

    arguments
        artifactsDir (1,1) string
        outputMarkdown (1,1) string
    end

    fileMap = loadAndMergeXml(artifactsDir);

    summary = buildMarkdown(fileMap);
    fprintf("\n%s\n", summary);

    parentDir = fileparts(outputMarkdown);
    if strlength(parentDir) > 0 && ~isfolder(parentDir)
        mkdir(parentDir);
    end
    writelines(summary, outputMarkdown);
    fprintf("Wrote %s\n", outputMarkdown);
end

function fileMap = loadAndMergeXml(artifactsDir)
    xmlFiles = dir(fullfile(artifactsDir, '**', 'cobertura.xml'));
    assert(~isempty(xmlFiles), "mergeCoverageReports:noFiles", ...
        "No cobertura.xml files found in %s", artifactsDir);
    fprintf("Merging %d Cobertura XML report(s)\n", numel(xmlFiles));

    fileMap = dictionary(string.empty, cell.empty);

    for i = 1:numel(xmlFiles)
        xmlPath = fullfile(xmlFiles(i).folder, xmlFiles(i).name);
        fprintf("  %s\n", xmlPath);
        doc = xmlread(xmlPath);

        classes = doc.getElementsByTagName("class");
        for c = 0:classes.getLength()-1
            classNode = classes.item(c);
            filename = string(classNode.getAttribute("filename"));
            filename = replace(filename, "\", "/");

            lines = classNode.getElementsByTagName("line");
            for l = 0:lines.getLength()-1
                lineNode = lines.item(l);
                num = int32(str2double(lineNode.getAttribute("number")));
                hits = int32(str2double(lineNode.getAttribute("hits")));

                if isKey(fileMap, filename)
                    lineData = fileMap{filename};
                else
                    lineData = dictionary(int32.empty, int32.empty);
                end

                if isKey(lineData, num)
                    lineData(num) = max(lineData(num), hits);
                else
                    lineData(num) = hits;
                end
                fileMap(filename) = {lineData};
            end
        end
    end
end

function summary = buildMarkdown(fileMap)
    filenames = sort(keys(fileMap));
    coveredTotal = 0;
    linesTotal = 0;

    rows = strings(1, numel(filenames));
    details = strings(1, numel(filenames));
    for i = 1:numel(filenames)
        lineData = fileMap{filenames(i)};
        lineNums = sort(keys(lineData));
        hitsArray = lineData(lineNums);
        nTotal = numel(lineNums);
        nCovered = sum(hitsArray > 0);
        coveredTotal = coveredTotal + nCovered;
        linesTotal = linesTotal + nTotal;

        if nTotal == 0
            rows(i) = sprintf("| %s | N/A | 0/0 |", filenames(i));
        else
            rate = nCovered / nTotal * 100;
            rows(i) = sprintf("| %s | %.1f%% | %d/%d |", ...
                filenames(i), rate, nCovered, nTotal);
        end

        uncoveredLines = lineNums(hitsArray == 0);
        if ~isempty(uncoveredLines)
            lineList = join(string(uncoveredLines), ", ");
            details(i) = sprintf( ...
                "<details><summary>%s — %d uncovered line(s)</summary>\n\nLines: %s\n\n</details>", ...
                filenames(i), numel(uncoveredLines), lineList);
        end
    end

    overallRate = coveredTotal / linesTotal * 100;
    isPartial = false(1, numel(filenames));
    for i = 1:numel(filenames)
        lineData = fileMap{filenames(i)};
        lineNums = keys(lineData);
        hitsArray = lineData(lineNums);
        nTotal = numel(lineNums);
        nCovered = sum(hitsArray > 0);
        isPartial(i) = nTotal > 0 && nCovered < nTotal;
    end

    md = strings(0);
    md(end+1) = "### Combined Code Coverage";
    md(end+1) = "";
    md(end+1) = sprintf("**Overall: %.1f%% statement coverage (%d/%d)**", ...
        overallRate, coveredTotal, linesTotal);

    if any(isPartial)
        md(end+1) = "";
        md(end+1) = "#### Files Without Full Coverage";
        md(end+1) = "";
        md(end+1) = "| File | Coverage | Statements |";
        md(end+1) = "|------|-------:|-----------:|";
        md = [md, rows(isPartial)];
    end

    hasDetails = strlength(details) > 0;
    if any(hasDetails)
        md(end+1) = "";
        md(end+1) = "#### Uncovered Lines";
        md(end+1) = "";
        md = [md, details(hasDetails)];
    end

    md(end+1) = "";
    md(end+1) = "<details><summary><strong>All Files</strong></summary>";
    md(end+1) = "";
    md(end+1) = "| File | Coverage | Statements |";
    md(end+1) = "|------|-------:|-----------:|";
    md = [md, rows];
    md(end+1) = "";
    md(end+1) = "</details>";

    summary = join(md, newline);
end
