inputs:

let
  profiles = import ../profiles inputs;
in
{
  nixos = { ... }: {
    imports = [ profiles.pi5Image.nixos ];
  };
}
