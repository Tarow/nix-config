dashboardPath: {
  apiVersion = 1;
  providers = [
    {
      name = "Dashboard Provider";
      orgId = 1;
      type = "file";
      disableDeletion = false;
      updateIntervalSeconds = 10;
      allowUiUpdates = false;
      options = {
        path = dashboardPath;
        foldersFromFilesStructure = true;
      };
    }
  ];
}
