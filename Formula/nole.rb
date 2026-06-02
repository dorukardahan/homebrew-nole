# Homebrew formula TEMPLATE for the dorukardahan/homebrew-nole tap.
#
# This is the reviewable source of truth. The release workflow renders it (filling
# the version and the four per-asset sha256 placeholders from the published
# SHA256SUMS) and pushes the result to Formula/nole.rb in the tap repo, so `brew install
# dorukardahan/nole/nole` always tracks the latest release. (Auto-push requires a
# HOMEBREW_TAP_TOKEN secret; when it is absent the release workflow skips the sync
# and the formula is bumped manually — see docs/PACKAGING.md.)
#
# Prebuilt-binary formula (NOT build-from-source): the release binary already carries
# the version/commit/date ldflags stamp, so `nole version` and `doctor
# --check-updates` report correctly. A source-build formula would print `nole dev`
# forever — do not switch to one without replicating the
# internal/version.{Version,Commit,Date} ldflags from scripts/check-release-builds.sh.
# Stanza order is FIXED by Homebrew's FormulaAudit/ComponentsOrder cop (verified
# against `brew audit --strict`): desc, homepage, version, license, livecheck,
# on_macos, on_linux, install, caveats, test. livecheck MUST precede the on_* url
# blocks and caveats MUST precede test — do not reorder.
class Nole < Formula
  desc "Dumb-but-excellent internet gateway for frontier agents"
  homepage "https://github.com/dorukardahan/nole"
  version "1.2.1"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/dorukardahan/nole/releases/download/v#{version}/nole-darwin-arm64"
      sha256 "832f03aec2d43e81b874073f88c95463a7c04f9fa6853fb5e37eaa220e1b2eb5"
    end
    on_intel do
      url "https://github.com/dorukardahan/nole/releases/download/v#{version}/nole-darwin-amd64"
      sha256 "b4c025139113dd22e6072c91f6b01f2b75ec0f1a761a790ad2a4e6ea355520f6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dorukardahan/nole/releases/download/v#{version}/nole-linux-arm64"
      sha256 "d3d2591d518559afad2ad825acf3d61691379c237ae3b9b44b587dc696430fed"
    end
    on_intel do
      url "https://github.com/dorukardahan/nole/releases/download/v#{version}/nole-linux-amd64"
      sha256 "0fca0d3b64ffdcc76b214b952a2d2e8ebc7d4e167ed4dae63020ed03270ec46f"
    end
  end

  def install
    # Homebrew fetches ONLY the single per-platform asset named nole-<os>-<arch>
    # (SHA256SUMS is not referenced by the formula, so it is never downloaded). Pin
    # to that exact shape and exclude any stray non-binary file defensively, then
    # install it as `nole`.
    binary = Dir["nole-*"].reject { |f| f.end_with?("SHA256SUMS") }.first
    bin.install binary => "nole"
  end

  def caveats
    <<~EOS
      Nólë release binaries are signed with keyless GitHub build provenance.
      To verify the installed binary (optional, needs the GitHub CLI):
        gh attestation verify "$(brew --prefix)/bin/nole" --repo dorukardahan/nole
    EOS
  end

  test do
    # The release binary stamps version.Version to the git tag ("vX.Y.Z"); the
    # formula's `version` is "X.Y.Z" (Homebrew convention, no leading v). Match the
    # bare number so the leading-v difference does not fail the test.
    assert_match version.to_s, shell_output("#{bin}/nole version")
  end
end
