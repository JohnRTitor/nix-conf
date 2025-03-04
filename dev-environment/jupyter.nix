{pkgs, ...}: {
  services.jupyter = {
    enable = true;
    password = "argon2:$argon2id$v=19$m=10240,t=10,p=8$PxYTOOaulhqndkeAsBaiVQ$cwS31ODwiduBmA59YYTfh2q8SbMBGH93iDjU5tcQ8kU";
  };

  #services.jupyter.notebookDir = "Notebooks";
}
