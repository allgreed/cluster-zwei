let
    agent = import ./logic/agent.nix;
    knight0Phy = import ./phy/knight0.nix;
    knight1Phy = import ./phy/knight1.nix;
    knight2Phy = import ./phy/knight2.nix;
in
{
    # TODO: pretify it
    knight0 = { config, pkgs, nodes, ... }: agent { inherit config; inherit pkgs; inherit nodes;}
      // knight0Phy { inherit config; inherit pkgs; inherit nodes;};

    knight1 = { config, pkgs, nodes, ... }: agent { inherit config; inherit pkgs; inherit nodes;}
      // knight1Phy { inherit config; inherit pkgs; inherit nodes;};

    knight2 = { config, pkgs, nodes, ... }: agent { inherit config; inherit pkgs; inherit nodes;}
      // knight2Phy { inherit config; inherit pkgs; inherit nodes;};
}
