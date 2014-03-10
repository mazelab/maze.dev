Feature: Login process
    As a maze user
    I want a login process

    Background:
        Given I use a browser width of "1024"

    Scenario: A forgot password function
        Given I am on "/"
        When I follow "linkForgotPassword"
        Then I should see an "#userEmail" element
        When I fill in "userEmail" with "hsgfz"
        And  I press "resend-password"
        Then I should see an errormessage


    Scenario: Wrong password should access deny
        Given I am on "/"
        When I fill in "username" with "admin"
        And  I fill in "password" with "wrongAndEvil"
        And  I press "login"
        Then I should not see an "img#jsAvatar" element
        Then I should see an "#password" element