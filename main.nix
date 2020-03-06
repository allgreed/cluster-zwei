let
    agent = import ./logic/agent.nix;
    knight0Phy = import ./phy/knight0.nix;
in
{
    # TODO: pretify it
    knight0 = { config, pkgs, nodes, ... }: agent { inherit config; inherit pkgs; inherit nodes;}
      // knight0Phy { inherit config; inherit pkgs; inherit nodes;};
}
