<?php

final class ScoreFiveUnitTestEngine extends ArcanistUnitTestEngine {

    protected $console;
    protected $renderer;

    public function init() {
        $config_manager = $this->getConfigurationManager();
        $this->console = PhutilConsole::getConsole();
        $this->renderer = new ArcanistUnitConsoleRenderer();
    }

    public function run() {
        $results = array();
        $this->init();
        
        $results[] = $this->updateSfTool();
        $results[] = $this->checkTuist();
        return $results;
    }
    
    public function shouldEchoTestResults() {
        return false;
    }
    
    private function checkTuist() {
        $result = new ArcanistUnitTestResult();
        $result->setName("Check Workspace Manifest");
        $this->console->writeOut("%s %s",
          phutil_console_format('<bg:yellow>** RUN **</bg>'),
          $result->getName()
        );
        try {
            list($stdout, $stderr) = execx(`./sftool develop --arcunit`);
            $result->setResult(ArcanistUnitTestResult::RESULT_PASS);
            $this->console->writeOut("\r%s", $this->renderer->renderUnitResult($result));
        } catch(CommandException $exc) {
            $result->setUserdata($exc->getStdout() . "\n" . $exc->getStderr());
            $result->setResult(ArcanistUnitTestResult::RESULT_FAIL);
            $this->console->writeOut("\r%s", $this->renderer->renderUnitResult($result));
        }
        return $result;
    }
    
    private function updateSfTool() {
        $result = new ArcanistUnitTestResult();
        $result->setName("Update SFTool");
        $this->console->writeOut("%s %s",
          phutil_console_format('<bg:yellow>** RUN **</bg>'),
          $result->getName()
        );
        try {
            list($stdout, $stderr) = exec_manual(`./update-sftool.sh`);
            $result->setResult(ArcanistUnitTestResult::RESULT_PASS);
            $this->console->writeOut("\r%s", $this->renderer->renderUnitResult($result));
        } catch(CommandException $exec) {
            $result->setUserdata($exc->getStdout() . "\n" . $exc->getStderr());
            $result->setResult(ArcanistUnitTestResult::RESULT_FAIL);
            $this->console->writeOut("\r%s", $this->renderer->renderUnitResult($result));
        }
        return $result;
    }
}

?>
