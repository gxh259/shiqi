cask "shiqi" do
  version "1.4.0"
  sha256 "8d7038f42829c37c21eb412631a666132e4f9b77f1a8fe5fa05809cdd21b53aa"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
