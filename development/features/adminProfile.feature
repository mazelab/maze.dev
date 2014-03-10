@usermanagement
Feature: Profile Management
  In order to manage the profile settings
  As a administrator
  I want to use the admin interface case

  Background:
    Given I use a browser width of "1024"
    Given I am logged in as admin

  Scenario: Click the profile menu
    Given I am on "/"
    When I click ".cssUserName"
    And I click "#myprofil"
    Then the url should match "/profile"
