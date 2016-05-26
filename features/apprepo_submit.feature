Feature: apprepo submit

  Docs
  
  Scenario: submit ipa and manifest
  Given an Apprepo
  When I send it the submit message
  Then I should see "SUCCESS"