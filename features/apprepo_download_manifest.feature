Feature: manifest download

  Docs
  
  Scenario: download manifest from sftp
  Given an Apprepo
  When I send it the download_manifest message
  Then I should see "Successfully fetched manifest"