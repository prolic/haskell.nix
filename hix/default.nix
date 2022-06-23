{ pkgs }:
let
  args = '' --arg userDefaults "$HOME/.config/hix/hix.conf" --arg src ./.'';
  # Use HIX_ROOT to override the version of hix used when developing new hix features.
  # See docs/dev/hix.md for details.
  hixProject = "\${HIX_ROOT:-${./..}}/hix/project";
in pkgs.symlinkJoin {
  name = "hix";
  paths = [
    (pkgs.writeScriptBin "hix-shell" ''
      nix-shell ${hixProject} ${args} -A shell "$@"
    '')
    (pkgs.writeScriptBin "hix-build" ''
      nix-build ${hixProject} ${args} "$@"
    '')
    (pkgs.writeScriptBin "hix-instantiate" ''
      nix-instantiate ${hixProject} ${args} "$@"
    '')
    (pkgs.writeScriptBin "hix-env" ''
      nix-env -f ${hixProject} ${args} "$@"
    '')
    (pkgs.writeScriptBin "hix" ''
      cmd=$1
      shift
      case $cmd in
      update)
        nix-env -iA hix -f https://github.com/input-output-hk/haskell.nix/tarball/master
        ;;
      dump-path|eval|log|path-info|run|search|show-derivation|sign-paths|verify|why-depends)
        nix $cmd -f ${hixProject} ${args} "$@"
        ;;
      build)
        target=$1
        shift
        case $target in
        *#*)
          nix build "path:${hixProject}#''${target#*#}" --override-input src ''${target%%#*} "$@"
          ;;
        *)
          echo $target
          nix $cmd -f ${hixProject} ${args} "$target" "$@"
          ;;
        esac
        ;;
      develop)
        nix $cmd "path:${hixProject}" --override-input src ./. "$@"
        ;;
      flake)
        cmd=$1
        shift
        case $cmd in
        lock|update)
          echo "error: hix does not support lock files" 1>&2
          exit 1
          ;;
        archive|check|clone|info|metadata|prefetch|show)
          nix flake $cmd "path:${hixProject}" --override-input src ./. "$@"
          ;;
        *)
          nix flake $cmd "$@"
          ;;
        esac
        ;;
      repl)
        nix $cmd ${hixProject} ${args} "$@"
        ;;
      *)
        nix $cmd "$@"
        ;;
      esac
    '')
  ];
}
