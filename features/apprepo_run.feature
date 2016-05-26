Feature: apprepo run

  Docs
  
  Scenario: submit ipa and manifest
  Given an Apprepo
  When I send it the run message
  Then I should see "IPA upload successful"
  Then I should see "Manifest upload successful"