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
  version "1.2.3"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/dorukardahan/nole/releases/download/v#{version}/nole-darwin-arm64"
      sha256 "27fd53075f8cf5cea960807d4f67aed7543549e124d27a2d824fcf81879515d0"
    end
    on_intel do
      url "https://github.com/dorukardahan/nole/releases/download/v#{version}/nole-darwin-amd64"
      sha256 "590eae2a2eefe9b02c84d922b31c5b83e36edcc307fbe1fbff7e9c4b5da0b2b4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dorukardahan/nole/releases/download/v#{version}/nole-linux-arm64"
      sha256 "ef38a8f7fb6d8294b0f5ef75f7ebeaf38e250417f7177df67024a1812c72c3a3"
    end
    on_intel do
      url "https://github.com/dorukardahan/nole/releases/download/v#{version}/nole-linux-amd64"
      sha256 "dce7dc78abf4301776098c00892936532652f0521a93de71be4b92849b8ae838"
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
