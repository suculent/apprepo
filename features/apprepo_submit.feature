Feature: apprepo submit

  Docs
  
  Scenario: submit ipa and manifest
  Given an Uploader
  When I send it the upload message
  Then I should see "SUCCESS"