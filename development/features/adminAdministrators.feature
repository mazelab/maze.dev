@usermanagement
Feature: System administrators settings

  Background:
    Given I use a browser width of "1024"
    Given I am logged in as admin

  Scenario: self login view
    display properties of current administrator

    Given I am in system settings tab administrators
    Then I should see a vcard whith my admin login
    And I should not see an delete button on this card
    And I should not see an status button on this card
