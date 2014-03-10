@clientmanagement
Feature: Add Client
  In order to create a Client
  As a administrator
  I want to create a new Client

  Background:
    Given I use a browser width of "1024"
    Given I am logged in as admin

  Scenario: Add Mandant
    Given I am on "/clients/add"
    When I fill in "company" with "Behattest AG"
    When I fill in "prename" with "Tom"
    When I fill in "surname" with "Tomson"
    When I fill in "street" with "Tomatensaft"
    When I fill in "houseNumber" with "22"
    When I fill in "postcode" with "01234"
    When I fill in "city" with "Tom Town"
    When I fill in "phone" with "152435434"
    When I fill in "email" with "tom.tomson@behattest.org"
    When I fill in "username" with "tomtom"
    When I fill in "password" with "tomtom"
    And I press "Save"
    Then I create a Client
