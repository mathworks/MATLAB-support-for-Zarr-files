function plan = buildfile
    %BUILDFILE Build tasks for MATLAB Support for Zarr Files.
    %   Run with `buildtool` from the repo root. See `buildtool -tasks` for the
    %   available tasks.

    addpath("buildUtilities");
    addpath("toolbox");

    plan = buildplan(localfunctions);

    plan.DefaultTasks = ["lint", "test"];

    plan("test").Dependencies = "lint";
    plan("fixLint").Dependencies = "indent";
    plan("all").Dependencies = ["indent", "fixLint", "test"];
end

function testTask(~)
    % Run the test suite in test/ against the toolbox on the path.
    %   Measures coverage of the toolbox library code and writes two reports
    %   into coverage/: cobertura.xml for CI consumption and html/index.html to
    %   browse locally.
    %   The suite runs with the working directory set to test/ because the
    %   tests resolve their dataFiles fixtures relative to pwd.
    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.CoberturaFormat
    import matlab.unittest.plugins.codecoverage.CoverageReport
    import matlab.unittest.plugins.codecoverage.CoverageResult

    projectRoot = pwd;
    coverageFolder = fullfile(projectRoot, "coverage");
    if ~isfolder(coverageFolder)
        mkdir(coverageFolder);
    end

    % Compute absolute library paths before changing directory.
    files = libraryFiles();

    coverageResult = CoverageResult;
    formats = [ ...
        CoberturaFormat(fullfile(coverageFolder, "cobertura.xml")), ...
        CoverageReport(fullfile(coverageFolder, "html")), ...
        coverageResult];

    cleanup = onCleanup(@() cd(projectRoot)); %#ok<NASGU>
    cd(fullfile(projectRoot, "test"));

    suite = TestSuite.fromFolder(pwd, IncludingSubfolders=true);
    runner = TestRunner.withTextOutput;
    runner.addPlugin(CodeCoveragePlugin.forFile(files, Producing=formats));
    results = runner.run(suite);
    assertSuccess(results);

    result = coverageResult.Result; %#ok<NASGU>
    save(fullfile(coverageFolder, "result.mat"), "result");
end

function mltbxTask(~)
    % Package toolbox/ into a .mltbx artifact.
    % Temporarily copy license.txt and README.md into toolbox/ so they are
    % bundled in the .mltbx.
    sourcePath = ["license.txt" "README.md"];
    destPathFcn = @(filename) fullfile("toolbox", filename);
    arrayfun(@(filename) copyfile(filename, destPathFcn(filename)), sourcePath);
    cleanup = onCleanup(@() delete(destPathFcn(sourcePath))); %#ok<NASGU>

    % Don't ship Python bytecode cache.
    pycache = fullfile("toolbox", "PythonModule", "__pycache__");
    if isfolder(pycache)
        rmdir(pycache, "s");
    end

    opts = matlab.addons.toolbox.ToolboxOptions("toolbox", ...
        "54873694-120e-4bde-bec8-ffe93cc848cd", ...
        ToolboxName="MATLAB Support for Zarr Files");
    opts.ToolboxVersion = "0.1.0";
    opts.MinimumMatlabRelease = "R2024a";
    opts.OutputFile = fullfile("release", "MATLAB_Support_for_Zarr_Files.mltbx");
    opts.Summary = "Read and write Zarr v2 arrays and metadata from local storage and Amazon S3.";
    opts.Description = fileread("README.md");
    imageFile = fullfile("images", "matlab-support-for-zarr-files.png");
    if isfile(imageFile)
        opts.ToolboxImageFile = imageFile;
    end
    opts.AuthorCompany = "MathWorks";
    opts.AuthorName = "MathWorks";

    if ~isfolder("release")
        mkdir("release");
    end
    matlab.addons.toolbox.packageToolbox(opts);
end

%% ---- Formatting and static analysis ----------------------------------------

function indentTask(~)
    % Auto-indent all project .m files using MATLAB smart indentation.
    s = settings;
    s.matlab.editor.tab.IndentSize.TemporaryValue = 4;
    s.matlab.editor.tab.InsertSpaces.TemporaryValue = true;
    s.matlab.editor.language.matlab.FunctionIndentingFormat.TemporaryValue = ...
        "AllFunctionIndent";

    files = projectMatlabFiles();
    modified = files(arrayfun(@smartIndentFile, files));
    if isempty(modified)
        fprintf("All %d files already correctly indented.\n", numel(files));
    else
        fprintf("Re-indented %d of %d files:\n", numel(modified), numel(files));
        for i = 1:numel(modified)
            fprintf("  %s\n", modified(i));
        end
    end
end

function lintTask(~)
    % Report Code Analyzer issues in the toolbox library source.
    issues = codeIssues(libraryFiles());
    t = issues.Issues;

    if isempty(t)
        fprintf("No code issues found.\n");
        return
    end

    columns = ["Location", "Severity", "CheckID", "Description"];
    if ismember("Fixability", t.Properties.VariableNames)
        columns = ["Location", "Severity", "Fixability", "CheckID", "Description"];
    end
    disp(t(:, columns));
    nWarnings = sum(t.Severity == "warning");
    nInfo = height(t) - nWarnings;
    fprintf("\n%d warning(s), %d info\n", nWarnings, nInfo);

    if nWarnings > 0
        error("lint:warnings", "Code Analyzer found %d warning(s).", nWarnings);
    end
end

function fixLintTask(~)
    % Auto-fix Code Analyzer issues in the toolbox library source.
    issues = codeIssues(libraryFiles());
    t = issues.Issues;

    if isempty(t)
        fprintf("No code issues found.\n");
        return
    end

    autoFixable = t(t.Fixability == "auto", :);
    if ~isempty(autoFixable)
        [~, results] = fix(issues, autoFixable);
        fprintf("Auto-fixed %d of %d issue(s).\n", sum(results.Success), height(results));
    end

    manual = t(t.Fixability == "manual", :);
    if ~isempty(manual)
        fprintf("\nRemaining issues (require manual fix):\n");
        disp(manual(:, ["Location", "Severity", "CheckID", "Description"]));
    end
end

function allTask(~)
    % Auto-format, fix lint issues, and run the test suite.
    %   Orchestrated via dependencies: indent -> fixLint -> test (which includes lint).
end

% Copyright 2026 The MathWorks, Inc.
