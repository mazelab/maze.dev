<?php

use Behat\Behat\Context\Step;
use Behat\Behat\Event\StepEvent;
use Behat\Behat\Event\SuiteEvent;
use Behat\Behat\Exception\PendingException;
use Behat\MinkExtension\Context\MinkContext;
use Symfony\Component\EventDispatcher\GenericEvent;
use Symfony\Component\Process\Exception\RuntimeException;
use Symfony\Component\Process\Process;

/**
 * Features context.
 */
class FeatureContext extends MinkContext
{
    static $registerSuiteDoneEvent = 0;

    /**
     * Initializes context.
     * Every scenario gets it's own context object.
     *
     * @param array $parameters context parameters (set them up through behat.yml)
     */
    public function __construct(array $parameters)
    {
        // Initialize your context here
    }

    /** @BeforeSuite */
    public static function setup(SuiteEvent $event)
    {
        $process = new Process('phantomjs --webdriver=8643 --proxy-type=none --ignore-ssl-errors=true');
        $output = new GenericEvent();
        $process->setTimeout(null);
        $process->start(function ($type, $buffer) use ($process,$output) {
            $output->setArgument('output', $process->getIncrementalOutput());
        });
        $phantomjsOnline = false;
        $portScan = false;
        while (! $phantomjsOnline) {
            if ($output->hasArgument('output')) {
                $portScan = strpos($output->getArgument('output'), 'running on port 8643');
            }
            if ($portScan) {
                echo $output->getArgument('output');
            }
            $phantomjsOnline = $process->isStarted() && $process->isRunning() && $portScan;
            if ($process->isTerminated()) {
                throw new RuntimeException('Phantomjs could not been started with webdriver on port 8643');
            }
        }
        self::$registerSuiteDoneEvent++;
    }

    /** @AfterSuite */
    public static function teardown(SuiteEvent $event)
    {
        self::$registerSuiteDoneEvent--;
    }

    public function __destruct() {
        if (self::$registerSuiteDoneEvent === 0) exec("ps a|grep 'phantomjs.*8643' && ps a|grep 'phantomjs.*8643'|grep -v grep | awk '{print $1}'| xargs kill");
    }

    /**
     * @AfterStep
     */
    public function after(StepEvent $event)
    {
        if ($event->getResult() === 4) {
            $session = $this->getSession();
            file_put_contents(
                'errors/scenario_'.$event->getStep()->getParent()->getTitle().'.png',
                $session->getScreenshot()
            );
        }
    }

    /**
     * @Then /^display response status code$/
     */
    public function displayResponseStatusCode()
    {
        $this->printDebug($this->getSession()->getStatusCode());
    }

    /**
     * @Given /^display response content$/
     */
    public function displayResponseContent()
    {
        $this->printLastResponse();
    }
    
    /**
     * @When /^I click "([^"]*)"$/
     */
    public function iClick($arg1)
    {
        $element = $this->getSession()
            ->getPage()
            ->find("css", "$arg1");
        // errors must not pass silently
        if (null === $element) {
            throw new InvalidArgumentException(sprintf('Could not find element with "%s"', $arg1));
        }
        $element->click();
        $this->getSession()->wait(10000, '(0 === jQuery.active)');
    }


    /**
     * @Given /^I am logged in as admin$/
     */
    public function iAmLoggedInAsAdmin()
    {
        return array(
            new Step\Given('I am on "/"'),
            new Step\Given('I fill in "username" with "admin"'),
            new Step\Given('I fill in "password" with "admin"'),
            new Step\Given('I press "login"'),
            new Step\Given('I should not see an "password" element')
        );
    }


    /**
     * @Then /^I should see an errormessage$/
     */
    public function iShouldSeeAnErrormessage()
    {
        return array(
            new Step\Then('I should see an "ul.errors" element')
        );
    }

    /**
     * @Then /^I create a Client$/
     */
    public function iCreateAClient()
    {
        return array(
            new Step\Then('I should see an "a.jsIconDeleteTxt" element')
        );
    }

    /**
     * @Given /^I am in system settings tab administrators$/
     */
    public function iAmInSystemSettingsTabAdministrators()
    {
        return array(
            new Step\Given('I click "#settings"'),
            new Step\Given('I click "#system"'),
            new Step\Given('I click "#settings-admins"'),
        );
    }

    /**
     * @Then /^I should see a vcard whith my admin login$/
     */
    public function iShouldSeeAVcardWhithMyAdminLogin()
    {
        throw new PendingException();
    }

    /**
     * @Given /^I should not see an delete button on this card$/
     */
    public function iShouldNotSeeAnDeleteButtonOnThisCard()
    {
        throw new PendingException();
    }

    /**
     * @Given /^I should not see an status button on this card$/
     */
    public function iShouldNotSeeAnStatusButtonOnThisCard()
    {
        throw new PendingException();
    }

    /**
     * @Given /^I use a browser width of "([^"]*)"$/
     */
    public function iUseABrowserWidthOf2($arg1)
    {
        $this->getSession()->resizeWindow($arg1, 900, 'current');
    }
}
