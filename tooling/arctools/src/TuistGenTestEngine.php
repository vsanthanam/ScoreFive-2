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
        $this->execute();

        $results[] = $this->result;
        return $results;
    }

    private function saveAndEchoResultCode($result_code) {
        $this->result->setResult($result_code);
        $this->result->setName("Tuist Sanity");
        $this->renderer->renderUnitResult($this->result);
        // $this->console->writeOut("\r%s", $this->renderer->renderUnitResult($this->result));
    }

    private function execute() {
        $future = new ExecFuture("./sftool develop -d");
        $future->setTimeout(500);
        // $future->setEnv($this->env);
        $this->executeFuture($future);
    }

    private function executeFuture($future) {
        try {
            list($stdout, $stderr) = $future->resolvex();
            $this->saveAndEchoResultCode(ArcanistUnitTestResult::RESULT_PASS);
        } catch(CommandException $exc) {
            if ($future->getWasKilledByTimeout()) {
                $this->result->setUserData(
                    "Process stdout:\n" . $exc->getStdout() .
                    "\nProcess stderr:\n" . $exc->getStderr() .
                    "\nExceeded timeout of " . $this->timeout . " secs"
                );
            } else {
                $this->result->setUserdata($exc->getStdout() . "\n" . $exc->getStderr());
            }
            $this->saveAndEchoResultCode(ArcanistUnitTestResult::RESULT_FAIL);
        }
    }
}

?>
