function results = run_coverage()
% RUN_COVERAGE Run the full Zarr test suite with code coverage.
%   Measures line coverage over the source folder (repo root, excluding
%   the test/ folder), mirroring what CI collects. Produces an HTML report
%   and a Cobertura XML under test/, and prints a per-test pass/fail table.
%
%   Run from anywhere; paths are resolved relative to this file.

% Copyright 2026 The MathWorks, Inc.

import matlab.unittest.TestRunner
import matlab.unittest.Verbosity
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport
import matlab.unittest.plugins.codecoverage.CoberturaFormat

repoRoot  = fileparts(fileparts(mfilename('fullpath')));
testFolder = fullfile(repoRoot, 'test');

suite  = testsuite(testFolder, 'IncludeSubfolders', true);
runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Terse);

reportDir = fullfile(testFolder, 'coverageReport');
if ~isfolder(reportDir)
    mkdir(reportDir);
end

% Cover the source folder but not the tests themselves (matches codecov.yml).
runner.addPlugin(CodeCoveragePlugin.forFolder(repoRoot, ...
    'Producing', [ ...
        CoverageReport(reportDir), ...
        CoberturaFormat(fullfile(testFolder, 'cobertura.xml'))]));

results = runner.run(suite);

disp(table([results.Passed]', [results.Failed]', [results.Incomplete]', ...
    'VariableNames', {'Passed','Failed','Incomplete'}, ...
    'RowNames', {results.Name}));
end
