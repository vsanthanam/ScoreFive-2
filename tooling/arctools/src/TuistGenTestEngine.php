<?php

final class TuistGenTestEngine extends ArcanistUnitTestEngine {

    protected $console;
    protected $renderer;
    protected $result;

    public function init() {
        $config_manager = $this->getConfigurationManager();
        $this->console = PhutilConsole::getConsole();
        $this->renderer = new ArcanistUnitConsoleRenderer();
        $this->result = new ArcanistUnitTestResult();
    }

    public function run() {
        $results = array();
        $this->init();
        $this->console->writeOut("  %s %s",
          phutil_console_format('<bg:yellow>** RUN **</bg>'),
          $this->result->getName()
        );
        try {
            list($stdout, $stderr) = execx(`./sftool develop --arcunit`);
            $this->result->setResult(ArcanistUnitTestResult::RESULT_PASS);
            $this->result->setName("Check Manifest Sanity");
            $this->console->writeOut("\r%s", $this->renderer->renderUnitResult($this->result));
        } catch(CommandException $exc) {
            $this->result->setUserdata($exc->getStdout() . "\n" . $exc->getStderr());
            $this->result->setResult(ArcanistUnitTestResult::RESULT_FAIL);
            $this->result->setName("Check Manifest Sanity");
            $this->console->writeOut("\r%s", $this->renderer->renderUnitResult($this->result));
        }

        $results[] = $this->result;
        return $results;
    }
    
    public function shouldEchoTestResults() {
        return false;
    }
}

?>
