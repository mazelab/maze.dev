#----------------------------------
# maze.core/administration/dasboard
#----------------------------------
    
Feature: Maze dashboard

    Background:
    Given I use a browser width of "1024"
    Given I am logged in as admin

    Scenario: Edit Profile 
        Given I am on "/"
        When I follow "goToNodes"
        Then I should be on "/nodes"

   