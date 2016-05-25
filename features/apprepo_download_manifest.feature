Feature: manifest download

  Docs
  
  Scenario: download manifest from sftp
  Given an Uploader
  When I send it the download_metadata message
  Then I should see "SUCCESS"